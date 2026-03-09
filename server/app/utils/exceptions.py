class InvalidYouTubeURL(ValueError):
    pass


class TranscriptNotAvailable(Exception):
    pass


class VideoNotFound(Exception):
    pass


class AIServiceError(Exception):
    pass
