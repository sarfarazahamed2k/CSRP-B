#!/bin/bash

# Define variables
userName="TimMedin"
domain="sarfarazahamed2018gmail.onmicrosoft.com"

# Delete the Azure AD user
az ad user delete --id "$userName@$domain"
