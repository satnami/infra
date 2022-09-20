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
  description = "satnami-ip-tv-generator"
}

variable "heroku_region" {
  description = "us"
}

resource "heroku_config" "common" {
  vars = {
    CACHE_TTL = "43200"
  }
  sensitive_vars = {
  }
}

resource "heroku_app" "ip_tv_generator" {
  name   = "satnami-ip-tv-generator"
  region = "us"
  stack  = "heroku-22"
}

resource "heroku_build" "ip_tv_generator" {
  app_id     = heroku_app.ip_tv_generator.id
  buildpacks = ["https://github.com/heroku/heroku-buildpack-nodejs"]
  source {
    url     = "https://github.com/satnami/ip-tv-generator/archive/refs/tags/0.1.3.tar.gz"
    version = "0.1.3"
  }
}

resource "heroku_domain" "ip_tv_generator" {
  app_id   = heroku_app.ip_tv_generator.id
  hostname = "m3u.satnami.xyz"
}

resource "heroku_formation" "ip_tv_generator" {
  app_id     = heroku_app.ip_tv_generator.id
  type       = "web"
  quantity   = 1
  size       = "free"
  depends_on = [heroku_build.ip_tv_generator]
}

resource "heroku_addon" "database" {
  app_id = heroku_app.ip_tv_generator.id
  plan   = "heroku-redis:hobby-dev"
}

resource "heroku_addon" "papertrail" {
  app_id = heroku_app.ip_tv_generator.id
  plan   = "papertrail:choklad"
}

resource "heroku_app_config_association" "vars" {
  app_id = heroku_app.ip_tv_generator.id

  vars           = heroku_config.common.vars
  sensitive_vars = heroku_config.common.sensitive_vars
}

output "ip_tv_generator_app_url" {
  value = "https://${heroku_app.ip_tv_generator.name}.herokuapp.com"
}