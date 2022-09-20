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
  description = "satnami-requestbin"
}

variable "heroku_region" {
  description = "us"
}

resource "heroku_app" "requestbin" {
  name   = "satnami-requestbin"
  region = "us"
  stack  = "heroku-16"
}

resource "heroku_build" "requestbin" {
  app_id     = heroku_app.requestbin.id
  buildpacks = ["https://github.com/heroku/heroku-buildpack-python"]
  source {
    url     = "https://github.com/satnami/requestbin/archive/v0.0.1.tar.gz"
    version = "0.0.1"
  }
}

resource "heroku_formation" "requestbin" {
  app_id     = heroku_app.requestbin.id
  type       = "web"
  quantity   = 1
  size       = "free"
  depends_on = [heroku_build.requestbin]
}

resource "heroku_addon" "database" {
  app_id = heroku_app.requestbin.id
  plan   = "heroku-redis:hobby-dev"
}

resource "heroku_addon" "papertrail" {
  app_id = heroku_app.requestbin.id
  plan   = "papertrail:choklad"
}

output "requestbin_app_url" {
  value = "https://${heroku_app.requestbin.name}.herokuapp.com"
}