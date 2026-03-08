#!/usr/bin/env python3
"""
API 계약 검증기: Python Pydantic 스키마 ↔ Dart API 클라이언트 필드 교차 대조

사용법:
  python3 verify-api-contract.py /path/to/project
  python3 verify-api-contract.py /path/to/project --json  # JSON 출력
"""

import ast
import glob
import json
import os
import re
import sys


# ─── Python 파서 ───────────────────────────────────────────────

def parse_pydantic_models(schema_path: str) -> dict[str, dict[str, dict]]:
    """Pydantic BaseModel 파싱 → {ModelName: {field: {type, required}}}"""
    with open(schema_path) as f:
        tree = ast.parse(f.read())

    models = {}
    for node in ast.walk(tree):
        if not isinstance(node, ast.ClassDef):
            continue
        # BaseModel 상속 확인
        is_base_model = any(
            (isinstance(b, ast.Name) and b.id == 'BaseModel') or
            (isinstance(b, ast.Attribute) and b.attr == 'BaseModel')
            for b in node.bases
        )
        if not is_base_model:
            continue

        fields = {}
        for item in node.body:
            if isinstance(item, ast.AnnAssign) and isinstance(item.target, ast.Name):
                field_name = item.target.id
                type_str = ast.unparse(item.annotation)
                has_default = item.value is not None
                fields[field_name] = {
                    'type': type_str,
                    'required': not has_default,
                }
        models[node.name] = fields

    return models


def parse_router_endpoints(router_path: str) -> dict[str, dict]:
    """FastAPI 라우터 파싱 → {endpoint_path: {method, request_model, response_model}}"""
    with open(router_path) as f:
        tree = ast.parse(f.read())

    endpoints = {}
    for node in ast.walk(tree):
        if not isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            continue

        for deco in node.decorator_list:
            # @router.post("/path", response_model=Model) 패턴
            if not isinstance(deco, ast.Call):
                continue
            if not isinstance(deco.func, ast.Attribute):
                continue

            method = deco.func.attr  # post, get, etc.
            if method not in ('post', 'get', 'put', 'delete', 'patch'):
                continue

            # 엔드포인트 경로
            path = None
            if deco.args and isinstance(deco.args[0], ast.Constant):
                path = deco.args[0].value

            # response_model
            response_model = None
            for kw in deco.keywords:
                if kw.arg == 'response_model':
                    response_model = ast.unparse(kw.value)

            # request model: 첫 번째 파라미터의 타입 어노테이션
            request_model = None
            args = node.args.args
            for arg in args:
                if arg.arg == 'self':
                    continue
                if arg.annotation:
                    ann = ast.unparse(arg.annotation)
                    if ann not in ('Request', 'Response'):
                        request_model = ann
                        break

            if path:
                endpoints[path] = {
                    'method': method,
                    'request_model': request_model,
                    'response_model': response_model,
                    'function': node.name,
                }

    return endpoints


# ─── Dart 파서 ─────────────────────────────────────────────────

def find_dart_api_files(app_dir: str) -> list[str]:
    """app/lib/ 하위에서 HTTP 호출을 포함하는 Dart 파일 탐색"""
    dart_files = glob.glob(os.path.join(app_dir, 'lib', '**', '*.dart'), recursive=True)
    api_files = []
    http_patterns = re.compile(r'http\.(post|get|put|delete|patch)|\.post\(|\.get\(', re.IGNORECASE)

    for f in dart_files:
        # generated 파일 제외
        if '.freezed.dart' in f or '.g.dart' in f:
            continue
        try:
            content = open(f).read()
            if http_patterns.search(content):
                api_files.append(f)
        except:
            pass

    return api_files


def find_dart_constants_file(app_dir: str) -> str | None:
    """ApiConstants 파일 탐색"""
    for f in glob.glob(os.path.join(app_dir, 'lib', '**', '*.dart'), recursive=True):
        try:
            content = open(f).read()
            if 'class ApiConstants' in content or 'Endpoint' in content:
                return f
        except:
            pass
    return None


def resolve_api_constants(app_dir: str) -> dict[str, str]:
    """ApiConstants 클래스에서 엔드포인트 URL 매핑 추출"""
    constants_file = find_dart_constants_file(app_dir)
    if not constants_file:
        return {}

    content = open(constants_file).read()
    mapping = {}
    # 패턴: xxxEndpoint ... /word_at_end_of_string'
    # 줄바꿈 포함 매칭 (re.DOTALL)
    for m in re.finditer(r'(\w+Endpoint)\b[\s\S]*?/(\w+)[\'"];', content):
        endpoint_name = m.group(1)
        path_segment = m.group(2)
        mapping[endpoint_name] = '/' + path_segment

    return mapping


def normalize_endpoint(path: str) -> str:
    """엔드포인트 경로 정규화: /api/v1/transcript → /transcript"""
    return re.sub(r'^/api/v\d+', '', path)


def parse_dart_api_client(file_path: str, constants: dict[str, str]) -> list[dict]:
    """Dart API 클라이언트에서 엔드포인트별 요청/응답 필드 추출"""
    content = open(file_path).read()
    endpoints = []

    # 메서드 블록 분리: Future<...> methodName(...)  async { ... }
    # 멀티라인 파라미터 지원: Future<...> methodName(\n  params\n) async {
    method_pattern = re.compile(
        r'Future<[^>]+>\s+(\w+)\s*\([\s\S]*?\)\s*async\s*\{',
    )

    method_starts = [(m.start(), m.group(1)) for m in method_pattern.finditer(content)]

    for i, (start, method_name) in enumerate(method_starts):
        # 메서드 블록 끝 추정: 다음 메서드 시작 또는 클래스 끝
        end = method_starts[i + 1][0] if i + 1 < len(method_starts) else len(content)
        block = content[start:end]

        # 엔드포인트 URL 추출
        endpoint = None

        # 패턴 1: 인라인 URL containing /api/v1/ or just /transcript etc.
        url_match = re.search(r"['\"\$].*?(/api/v\d+/\w+)", block)
        if url_match:
            endpoint = url_match.group(1)

        # 패턴 2: 인라인 URL '/transcript' etc. (without prefix)
        if not endpoint:
            url_match = re.search(r"['\"].*?(/(?:transcript|summarize|chat)\b)['\"]", block)
            if url_match:
                endpoint = url_match.group(1)

        # 패턴 3: ApiConstants.xxxEndpoint(...)
        if not endpoint:
            const_match = re.search(r'ApiConstants\.(\w+Endpoint)', block)
            if const_match and const_match.group(1) in constants:
                endpoint = constants[const_match.group(1)]

        if not endpoint:
            continue

        # 요청 필드: jsonEncode({...}) 내부 키 추출
        request_fields = []
        # 다중 줄 jsonEncode 블록
        json_match = re.search(r'jsonEncode\(\{([\s\S]*?)\}\)', block)
        if json_match:
            json_body = json_match.group(1)
            # 'key': value 패턴
            for key_match in re.finditer(r"'(\w+)':", json_body):
                request_fields.append(key_match.group(1))

        # 응답 필드: json['field'] 또는 ['field'] 패턴
        response_fields = []

        # fromJson 패턴: json['field_name'] 또는 data['field_name']
        for rf_match in re.finditer(r"\['\s*(\w+)\s*'\]", block):
            field = rf_match.group(1)
            # 'Content-Type' 등 헤더 제외
            if field not in ('Content-Type', 'content-type'):
                response_fields.append(field)

        # response 클래스의 fromJson도 파싱 (같은 파일에 정의된 경우)
        # 패턴: class XxxResponse { ... factory fromJson(json) { json['field'] } }

        # 구문 오류 탐지: ?variable (invalid Dart)
        syntax_errors = []
        for se_match in re.finditer(r"'(\w+)':\s*\?(\w+)", block):
            syntax_errors.append({
                'pattern': f"'{se_match.group(1)}': ?{se_match.group(2)}",
                'message': f"Invalid Dart syntax: '?{se_match.group(2)}' is not a valid expression",
            })

        endpoints.append({
            'method_name': method_name,
            'endpoint': endpoint,
            'request_fields': request_fields,
            'response_fields': response_fields,
            'syntax_errors': syntax_errors,
        })

    return endpoints


def parse_dart_response_classes(file_path: str) -> dict[str, list[str]]:
    """Dart 파일에서 Response/Model 클래스의 fromJson 필드 추출"""
    content = open(file_path).read()
    classes = {}

    # class ClassName { ... factory ClassName.fromJson(...) { ... } }
    class_pattern = re.compile(r'class\s+(\w+)\s*\{([\s\S]*?)(?=\nclass\s|\Z)')

    for cm in class_pattern.finditer(content):
        class_name = cm.group(1)
        class_body = cm.group(2)

        # fromJson 내부의 json['field'] 추출
        from_json_match = re.search(r'fromJson\s*\([\s\S]*?\{([\s\S]*?)\}\s*;?\s*\}', class_body)
        if from_json_match:
            fields = []
            for fm in re.finditer(r"json\['\s*(\w+)\s*'\]", from_json_match.group(1)):
                fields.append(fm.group(1))
            if fields:
                classes[class_name] = fields

    return classes


# ─── 교차 대조 ─────────────────────────────────────────────────

def cross_reference(
    python_models: dict,
    python_endpoints: dict,
    dart_endpoints: list[dict],
    dart_response_classes: dict,
) -> list[dict]:
    """Python 스키마 ↔ Dart 필드 교차 대조 → 불일치 목록"""
    mismatches = []

    # Python 엔드포인트를 정규화된 키로 재매핑
    normalized_py = {}
    for path, info in python_endpoints.items():
        norm = normalize_endpoint(path)
        normalized_py[norm] = info

    for dart_ep in dart_endpoints:
        ep_path = dart_ep['endpoint']
        norm_ep = normalize_endpoint(ep_path)

        # Python 엔드포인트 찾기 (정규화된 경로로)
        py_ep = normalized_py.get(norm_ep)
        if not py_ep:
            mismatches.append({
                'endpoint': ep_path,
                'type': 'endpoint_not_found',
                'severity': 'WARNING',
                'detail': f"Dart calls {ep_path} but not found in Python router",
            })
            continue

        # ── 요청 필드 검증 ──
        req_model_name = py_ep.get('request_model')
        if req_model_name and req_model_name in python_models:
            py_req_fields = python_models[req_model_name]
            dart_req_fields = set(dart_ep['request_fields'])

            # Python 필수 필드 중 Dart에 없는 것
            for field, info in py_req_fields.items():
                if info['required'] and field not in dart_req_fields:
                    mismatches.append({
                        'endpoint': ep_path,
                        'type': 'missing_required_field',
                        'direction': 'request',
                        'severity': 'CRITICAL',
                        'python_field': field,
                        'dart_field': None,
                        'detail': f"Python requires '{field}' but Dart doesn't send it",
                    })

            # Dart가 보내지만 Python에 없는 필드
            for field in dart_req_fields:
                if field not in py_req_fields:
                    mismatches.append({
                        'endpoint': ep_path,
                        'type': 'extra_field',
                        'direction': 'request',
                        'severity': 'WARNING',
                        'python_field': None,
                        'dart_field': field,
                        'detail': f"Dart sends '{field}' but Python schema has no such field",
                    })

        # ── 응답 필드 검증 ──
        resp_model_name = py_ep.get('response_model')
        if resp_model_name and resp_model_name in python_models:
            py_resp_fields = set(python_models[resp_model_name].keys())

            # Dart 응답 필드: 메서드 블록의 직접 파싱 + fromJson 클래스
            dart_resp_fields = set(dart_ep['response_fields'])

            # fromJson 클래스에서도 필드 수집
            for cls_name, cls_fields in dart_response_classes.items():
                # 클래스 이름이 Response 모델과 관련 있는지 확인
                # TranscriptResponse, SummarizeResponse 등
                if resp_model_name.lower().replace('response', '') in cls_name.lower().replace('response', ''):
                    dart_resp_fields.update(cls_fields)

            # 일반적인 에러 처리 필드 제외
            dart_resp_fields.discard('detail')
            dart_resp_fields.discard('statusCode')

            # Dart가 읽지만 Python에 없는 응답 필드
            for field in dart_resp_fields:
                if field not in py_resp_fields:
                    mismatches.append({
                        'endpoint': ep_path,
                        'type': 'field_name_mismatch',
                        'direction': 'response',
                        'severity': 'CRITICAL',
                        'python_field': None,
                        'dart_field': field,
                        'detail': f"Dart reads json['{field}'] but Python Response has no '{field}' field. "
                                  f"Python fields: {sorted(py_resp_fields)}",
                    })

        # ── 구문 오류 ──
        for se in dart_ep['syntax_errors']:
            mismatches.append({
                'endpoint': ep_path,
                'type': 'syntax_error',
                'direction': 'request',
                'severity': 'CRITICAL',
                'detail': se['message'],
                'pattern': se['pattern'],
            })

    return mismatches


# ─── 메인 ──────────────────────────────────────────────────────

def find_file(project_dir: str, patterns: list[str]) -> str | None:
    """여러 패턴으로 파일 탐색"""
    for pattern in patterns:
        matches = glob.glob(os.path.join(project_dir, pattern), recursive=True)
        if matches:
            return matches[0]
    return None


def find_all_files(project_dir: str, patterns: list[str]) -> list[str]:
    """여러 패턴으로 파일 탐색 (중복 제거, __init__.py 제외)"""
    found = set()
    for pattern in patterns:
        for f in glob.glob(os.path.join(project_dir, pattern), recursive=True):
            if '__init__' not in f and '.venv' not in f:
                found.add(f)
    return sorted(found)


def verify(project_dir: str) -> dict:
    """프로젝트 디렉토리에서 API 계약 검증 실행"""
    result = {
        'project': project_dir,
        'status': 'unknown',
        'total_mismatches': 0,
        'critical_count': 0,
        'warning_count': 0,
        'mismatches': [],
        'parsed': {
            'python_models': 0,
            'python_endpoints': 0,
            'dart_api_files': 0,
            'dart_endpoints': 0,
        },
        'errors': [],
    }

    # Python 스키마 탐색 (단일 파일 또는 디렉토리)
    schema_files = find_all_files(project_dir, [
        'server/models/schemas.py',
        'server/**/schemas.py',
        'server/**/schemas/*.py',
        'backend/models/schemas.py',
        'backend/**/schemas/*.py',
        '**/schemas.py',
        '**/schemas/*.py',
    ])
    if not schema_files:
        result['errors'].append('schemas.py not found')
        result['status'] = 'error'
        return result

    # Python 라우터 탐색 (단일 또는 복수 파일)
    router_files = find_all_files(project_dir, [
        'server/routers/api_v1.py',
        'server/routers/api*.py',
        'server/**/api*.py',
        'server/api/v1/*.py',
        'server/**/api/v1/*.py',
        'server/**/api/**/*.py',
        'server/**/routers/*.py',
        'backend/routers/api*.py',
        '**/routers/*.py',
    ])
    if not router_files:
        result['errors'].append('router file not found')
        result['status'] = 'error'
        return result

    # 파싱 (여러 파일에서 모델/엔드포인트 수집)
    python_models = {}
    for sf in schema_files:
        try:
            python_models.update(parse_pydantic_models(sf))
        except Exception:
            pass
    python_endpoints = {}
    for rf in router_files:
        try:
            python_endpoints.update(parse_router_endpoints(rf))
        except Exception:
            pass
    result['parsed']['python_models'] = len(python_models)
    result['parsed']['python_endpoints'] = len(python_endpoints)

    # Dart API 파일 탐색
    app_dir = os.path.join(project_dir, 'app')
    if not os.path.isdir(app_dir):
        result['errors'].append('app/ directory not found')
        result['status'] = 'error'
        return result

    dart_api_files = find_dart_api_files(app_dir)
    if not dart_api_files:
        result['errors'].append('No Dart API client files found')
        result['status'] = 'error'
        return result

    result['parsed']['dart_api_files'] = len(dart_api_files)

    # ApiConstants 해석
    constants = resolve_api_constants(app_dir)

    # Dart 파싱
    all_dart_endpoints = []
    all_dart_response_classes = {}

    for dart_file in dart_api_files:
        dart_eps = parse_dart_api_client(dart_file, constants)
        all_dart_endpoints.extend(dart_eps)
        resp_classes = parse_dart_response_classes(dart_file)
        all_dart_response_classes.update(resp_classes)

    result['parsed']['dart_endpoints'] = len(all_dart_endpoints)

    # 교차 대조
    mismatches = cross_reference(
        python_models, python_endpoints,
        all_dart_endpoints, all_dart_response_classes,
    )

    result['mismatches'] = mismatches
    result['total_mismatches'] = len(mismatches)
    result['critical_count'] = sum(1 for m in mismatches if m['severity'] == 'CRITICAL')
    result['warning_count'] = sum(1 for m in mismatches if m['severity'] == 'WARNING')
    result['status'] = 'pass' if result['critical_count'] == 0 else 'fail'

    return result


def print_report(result: dict):
    """사람이 읽기 좋은 형태로 출력"""
    print(f"\n{'=' * 60}")
    print(f"API Contract Verification: {result['project']}")
    print(f"{'=' * 60}")

    p = result['parsed']
    print(f"\nParsed: {p['python_models']} Python models, "
          f"{p['python_endpoints']} endpoints, "
          f"{p['dart_api_files']} Dart API files, "
          f"{p['dart_endpoints']} Dart endpoints")

    if result['errors']:
        for e in result['errors']:
            print(f"  ERROR: {e}")

    status_icon = '✅' if result['status'] == 'pass' else '❌' if result['status'] == 'fail' else '⚠️'
    print(f"\nStatus: {status_icon} {result['status'].upper()}")
    print(f"Total: {result['total_mismatches']} mismatches "
          f"({result['critical_count']} critical, {result['warning_count']} warning)")

    for m in result['mismatches']:
        icon = '🔴' if m['severity'] == 'CRITICAL' else '🟡'
        print(f"\n  {icon} [{m['severity']}] {m['endpoint']} ({m.get('direction', '')})")
        print(f"     {m['detail']}")

    print(f"\n{'=' * 60}")


def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <project_dir> [--json]")
        sys.exit(1)

    project_dir = sys.argv[1]
    json_mode = '--json' in sys.argv

    result = verify(project_dir)

    if json_mode:
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        print_report(result)

    sys.exit(0 if result['status'] == 'pass' else 1)


if __name__ == '__main__':
    main()
