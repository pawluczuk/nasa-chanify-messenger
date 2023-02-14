variable "user_information" {
  type = object({
    name    = string
  })
}

variable "CHANIFY_TOKEN" {
  type = string
  nullable = false
}

variable "NASA_API_KEY" {
  type = string
  nullable = false
}