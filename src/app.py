import uvicorn
from fastapi import FastAPI, Request, Depends

from pydantic import BaseModel
from mangum import Mangum
from os import environ as env
from glom import glom
from auth import verify_api_key
from route53 import Route53

route53 = Route53()

app_infra = env.get("APP_INFRASTRUCTURE")
api_key = env.get("API_KEY")

dependencies = [Depends(verify_api_key)] if api_key else None

app = FastAPI(docs_url=None if app_infra else '/docs',
              redoc_url=None if app_infra else '/redoc',
              openapi_url=None if app_infra else '/openapi.json',
              dependencies=dependencies)
handler = Mangum(app)


class requestSchema(BaseModel):
    domain: str
    hostname: str


class LambdaEvents(object):
    def __init__(self, request: Request):
      self.event = request.scope.get('aws.event')
      self.context = request.scope.get('aws.context')

    def get_source_ip_address(self):
        return glom(self.event, "requestContext.http.sourceIp",
                    default=None)


@app.post('/update')
async def update_ip_address(req: requestSchema, lambda_event=Depends(LambdaEvents)):
    ip_addr = lambda_event.get_source_ip_address()
    changed = route53.is_changed(hostname=req.hostname,
                                 domain=req.domain,
                                 ip_addr=ip_addr)
    if not changed:
        return {"detail": "not changed. avoiding update."}
    else:
        return route53.update_record(hostname=req.hostname,
                                     domain=req.domain,
                                     ip_addr=ip_addr)

if __name__ == "__main__" and not app_infra:
    uvicorn.run(
        app="app:app",
        port=int(env.get('FASTAPI_PORT', 8000)),
        host=env.get('FASTAPI_HOST', '0.0.0.0'),
        reload=bool(env.get('FASTAPI_RELOAD', False))
    )
