
# How to upgrade / install `go`

1. go to (https://go.dev/dl/) and download the latest version of go (xxx.tar.gz)

2. Execute the below
```bash
cd /usr/local/opt 
wget URL
rm -rf /usr/local/opt/go && tar -C /usr/local/opt -xzf go1.22.2.linux-amd64.tar.gz
mkdir -p /usr/local/opt/libexec
```

3. ensure the below line appeared in .zshenv
export GOROOT=/usr/local/opt/go/libexec

