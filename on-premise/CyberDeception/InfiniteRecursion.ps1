# Create dir1
New-Item -ItemType Directory -Force -Path "C:\Users\user_administrator\Desktop\dir1"

# Create symbolic links for dir2 pointing to dir1
cmd /c mklink /D "C:\Users\user_administrator\Desktop\dir1\dir2" "C:\Users\user_administrator\Desktop\dir1"

# Create symbolic links for dir3 pointing to dir1
cmd /c mklink /D "C:\Users\user_administrator\Desktop\dir1\dir3" "C:\Users\user_administrator\Desktop\dir1"
