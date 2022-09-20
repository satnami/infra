terraform {
  required_providers {
    heroku = {
      source  = "heroku/heroku"
      version = "5.1.4"
    }
  }
}

provider "heroku" {
}

# variable "heroku_email" {}
# variable "heroku_api_key" {}

variable "heroku_app_name" {
  description = "satnami-httpbin"
}

variable "heroku_region" {
  description = "us"
}

resource "heroku_app" "httpbin" {
  name   = "satnami-httpbin"
  region = "us"
  stack  = "heroku-18"
}

resource "heroku_build" "httpbin" {
  app_id     = heroku_app.httpbin.id
  buildpacks = ["https://github.com/heroku/heroku-buildpack-python"]
  source {
    url     = "https://github.com/maniacs-oss/httpbin/archive/v0.8.0.tar.gz"
    version = "0.8.0"
  }
}

resource "heroku_formation" "httpbin" {
  app_id     = heroku_app.httpbin.id
  type       = "web"
  quantity   = 1
  size       = "free"
  depends_on = [heroku_build.httpbin]
}

resource "heroku_addon" "papertrail" {
  app_id = heroku_app.httpbin.id
  plan   = "papertrail:choklad"
}

output "httpbin_app_url" {
  value = "https://${heroku_app.httpbin.name}.herokuapp.com"
}