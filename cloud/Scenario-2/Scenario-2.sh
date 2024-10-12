#!/bin/bash

# Define variables
userName="TimMedin"
userDisplayName="Tim Medin"
userPassword="P@ssw0rd!"
domain="sarfarazahamed2018gmail.onmicrosoft.com"
roleId="9f06204d-73c1-4d4c-880a-6edb90606fd8"

# Create a new user and capture the userId
userId=$(az ad user create --display-name "$userDisplayName" \
                           --password "$userPassword" \
                           --user-principal-name "$userName@$domain" \
                           --mail-nickname "$userName" \
                           --query 'id' \
                           --output tsv)

# Assign the user to the role
az rest --method POST --uri 'https://graph.microsoft.com/beta/roleManagement/directory/roleAssignments' \
                      --body "{'principalId': '$userId', 'roleDefinitionId': '$roleId', 'directoryScopeId': '/'}"