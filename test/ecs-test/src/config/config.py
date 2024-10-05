from functools import lru_cache

from pydantic.v1 import BaseSettings

class Config(BaseSettings):
    ENV: str = 'dev'

@lru_cache()
def get_config():
    return Config()