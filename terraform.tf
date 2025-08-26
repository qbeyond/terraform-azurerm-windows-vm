terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      #version = "~> 3.108"
      version = ">= 3.7.0"
    }
  }
}

