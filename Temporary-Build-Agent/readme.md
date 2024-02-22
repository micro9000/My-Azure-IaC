# Generate SSH Key

Generate SSH Key that we can use to connect to VM

Ensure you do not already have a public key saved to your computer. To determine if you already have a saved public key run the following command:

`cd ~/.ssh; ls -l`

If the directory and key file exist, run the following commands to back up the key id_rsa, as the procedure will overwrite any key named id_rsa in this directory:

```bash
mkdir key_backup
mv id_rsa* key_backup
```

Run the following command to generate a new public/private key pair:

`ssh-keygen -b 4096`

The ssh-keygen command prompts you for the directory to contain
the key.

```text
Generating public/private rsa key pair. Enter file in which to
save the key (/Users/[user_dir]/.ssh/id_rsa):
```

Press Enter to accept the default location of /.ssh/id_rsa in your user directory.

```text
Enter passphrase (empty for no passphrase): [passphrase] Enter same
passphrase again: [passphrase]
```

Substitute [passphrase] with your own unique, but memorable, text to encrypt the private key on your computer. Although you can use an empty passphrase, if you do, another user can impersonate you with only a copy of your key file (as there will be no required passphrase for additional confirmation of your identity).

Be sure to keep track of the passphrase, because you must enter the passphrase whenever you use the key.

The ssh-keygen command displays the following output message:

```text
Generating public/private rsa key pair. Your identification has been saved
in /Users/[user_dir]/.ssh/id_rsa. Your public key has been saved in
/Users/[user_dir]/.ssh/id_rsa.pub. The key fingerprint is:
52:96:e9:c8:06:c2:57:26:6d:ef:2f:0c:d9:81:f4:1c username@hostname
```

Copy the public key to your clipboard using a method available to your operating system