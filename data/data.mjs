const qb_list = [
  'qb-nox-static-419-lt1114',
  'qb-nox-static-419-lt1114-ax41',
  'qb-nox-static-419-lt1114-ln',
  'qb-nox-static-419-lt1114-12g',
  'qb-nox-static-419-lt1114-oracle',
  'qb-nox-static-438-lt1214',
  'qb-nox-static-439-lt1215'
];

const fileBrowser = (() => {
  `docker run -d --name fb \
    --restart=unless-stopped \
    -e PUID=$UID \
    -e PGID=$GID \
    -e WEB_PORT=8082 \
    -e FB_AUTH_SERVER_ADDR="127.0.0.1" \
    -p 8082:8082 \
    -v ~/docker/fb/config:/config \
    -v /:/myfiles \
    --mount type=tmpfs,destination=/tmp \
    80x86/filebrowser:2.9.4-amd64`
})

const qb_service = ((qb_version) => {
  return `[Unit]
Description=${qb_version}
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
User=%I
Type=simple
LimitNOFILE=100000
ExecStart=/usr/bin/${qb_version}
Restart=on-failure
TimeoutStopSec=20
RestartSec=10

[Install]
WantedBy=multi-user.target`
})

const qb_419_conf = ((username, md5password, port, webport) => {
  return `[LegalNotice]
Accepted=true
[Network]
Cookies=@Invalid()
[Preferences]
Connection\\PortRangeMin=${port}
General\\Locale=zh
General\\UseRandomPort=false
Downloads\\SavePath=/home/${username}/Downloads/
Queueing\\QueueingEnabled=false
WebUI\\Password_ha1=@ByteArray(${md5password})
WebUI\\Port=${webport}
WebUI\\Username=${username}
WebUI\\CSRFProtection=false`
})

const qb_438_conf = ((username, PBKDF2password, port, webport) => {
  return `[LegalNotice]
Accepted=true
[Network]
Cookies=@Invalid()
[Preferences]
Connection\\PortRangeMin=${port}
General\\Locale=zh
General\\UseRandomPort=false
Downloads\\PreAllocation=false
Downloads\\SavePath=/home/${username}/Downloads/
Queueing\\QueueingEnabled=false
WebUI\\Password_PBKDF2="@ByteArray(${PBKDF2password})"
WebUI\\Port=${webport}
WebUI\\Username=${username}
WebUI\\CSRFProtection=false`
})

const nginx_conf = (() => {
  return `server {  
      listen  80;
      server_name domain.com;
        
      rewrite ^(.*)$  https://$host$1 permanent; 
  }
  server {
      listen 443 ssl;
      server_name domain.com;
      index index.html index.htm;
      ssl_certificate /etc/nginx/ssl/fullchain.cer;
      ssl_certificate_key /etc/nginx/ssl/domain.com.key;
      ssl_session_timeout 5m;
      ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # TLS
      ssl_session_cache builtin:1000 shared:SSL:10m;
      error_page 404 /404.html;
      location / {
          proxy_pass http://127.0.0.1:webport/;
          proxy_http_version       1.1;
          proxy_set_header         X-Forwarded-Host        $http_host;
          http2_push_preload on; # Enable http2 push
      }
  }`
})

const data = {
  qb_list,
  fileBrowser,
  qb_service,
  qb_419_conf,
  qb_438_conf,
  nginx_conf
}

export default data