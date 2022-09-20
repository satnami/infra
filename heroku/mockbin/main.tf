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
  description = "satnami-mockbin"
}

variable "heroku_region" {
  description = "us"
}

resource "heroku_app" "mockbin" {
  name   = "satnami-mockbin"
  region = "us"
  stack  = "heroku-20"
}

resource "heroku_build" "mockbin" {
  app_id     = heroku_app.mockbin.id
  buildpacks = ["https://github.com/heroku/heroku-buildpack-nodejs"]
  source {
    url     = "https://github.com/maniacs-oss/mockbin/archive/v0.8.0.tar.gz"
    version = "0.8.0"
  }
}

resource "heroku_formation" "mockbin" {
  app_id     = heroku_app.mockbin.id
  type       = "web"
  quantity   = 1
  size       = "free"
  depends_on = [heroku_build.mockbin]
}

resource "heroku_addon" "database" {
  app_id = heroku_app.mockbin.id
  plan   = "heroku-redis:hobby-dev"
}

resource "heroku_addon" "papertrail" {
  app_id = heroku_app.mockbin.id
  plan   = "papertrail:choklad"
}

output "mockbin_app_url" {
  value = "https://${heroku_app.mockbin.name}.herokuapp.com"
}