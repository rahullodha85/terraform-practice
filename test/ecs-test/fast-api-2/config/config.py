from functools import lru_cache

from pydantic.v1 import BaseSettings

class Config(BaseSettings):
    ENV: str = 'dev'
    HOST: str = '0.0.0.0'
    PORT: int = 8001
    SERVICE_NAME: str = 'fast-api-2'
    API_PREFIX: str = ''

@lru_cache()
def get_config():
    return Config()