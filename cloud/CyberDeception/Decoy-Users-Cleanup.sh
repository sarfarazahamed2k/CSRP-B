#!/bin/bash

# Define variables for the users to be deleted
adminUserName="JohnStrandAdmin"
readerUserName="CoreyHam"
domain="sarfarazahamed2018gmail.onmicrosoft.com"

# Delete the first user (Global Administrator)
az ad user delete --id "$adminUserName@$domain"

# Delete the second user (Global Reader)
az ad user delete --id "$readerUserName@$domain"
