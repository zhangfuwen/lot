# lot
Linux on TNT

to start, run:

```bash
adb root
adb shell /data/data/com.termux/files/home/uoa/daemon.sh /data/data/com.termux/files/home/debian/debian3/
adb shell /data/data/com.termux/files/home/uoa/sys.sh stop /data/data/com.termux/files/home/debian/debian3/
```

to stop, run:

```bash
echo "1" > /data/data/com.termux/files/home/uoa/pipe1
```
