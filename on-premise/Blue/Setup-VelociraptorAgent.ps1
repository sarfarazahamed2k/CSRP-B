Invoke-WebRequest -Uri "https://github.com/Velocidex/velociraptor/releases/download/v0.72/velociraptor-v0.72.4-windows-amd64.exe" -OutFile "C:\Users\Public\velociraptor-v0.72.4-windows-amd64.exe"

Start-Process -FilePath "C:\Users\Public\velociraptor-v0.72.4-windows-amd64.exe" -ArgumentList "--config C:\Users\Public\client.config.yaml service install"