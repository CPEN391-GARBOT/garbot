import pysftp

with pysftp.Connection('169.254.184.14', username='root', password='password', port=22) as sftp:
    print("Connection successfully established")
    
    localpath = '/home/pi/garbot/ML/weights.bin'
    remotepath = '/home/root/Garbot/weights.bin'
    
    sftp.put(localpath, remotepath)