# Samsung-Galaxy-S7-herolte-LineageOS-18.1-build
Building out LineageOS 18.1 for the Galaxy S7 SM-G930F, SM-G930FD, SM-G930W8, SM-G930S/K/L (Exynos variants)

I wanted to rebuild LineageOS on an old Samsung Galaxy S7. I found that some of the general information inside the official instructions to be invalid or outdated.

This guid isn't for unlocking, bootloaders, or any of that jazz. It's just for getting LineageOS compiled for the phone. I hope it helps you.

## More official documentation
https://wiki.lineageos.org/devices/herolte/build/

## How to make it go:
**You might want to ensure you have sufficient hardware resources to do this using the LineageOS wiki link above if you are using your own hardware**
1. Download the .bash and .sh file
2. (Optional) Stand up your AWS hardware resource using `./launch-builder.sh --region us-east-1 --key-name lineage_config` (assuming your AWS region in this script - you can change it)
3. Copy the .bash script to your compilation machine (scp works well - or just paste it into a new file)
```
cat > compile.bash <<'EOF'
<paste script here>
EOF
```
4. Run the script with `bash compile.bash`
   **FYI** - This whole process will take you about 11 hours using the same hardware and AWS region I did. About 10.5 hours of that is down-time so I recommend doing it overnight.

Happy building.
