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
Connection\PortRangeMin=${port}
General\Locale=zh
General\UseRandomPort=false
Downloads\SavePath=/home/${username}/Downloads/
Queueing\QueueingEnabled=false
WebUI\Password_ha1=@ByteArray(${md5password})
WebUI\Port=${webport}
WebUI\Username=${username}
WebUI\CSRFProtection=false`
})

const qb_438_conf = ((username, PBKDF2password, port, webport) => {
  return `[LegalNotice]
Accepted=true
[Network]
Cookies=@Invalid()
[Preferences]
Connection\PortRangeMin=${port}
General\Locale=zh
General\UseRandomPort=false
Downloads\PreAllocation=false
Downloads\SavePath=/home/${username}/Downloads/
Queueing\QueueingEnabled=false
WebUI\Password_PBKDF2="@ByteArray(${PBKDF2password})"
WebUI\Port=${webport}
WebUI\Username=${username}
WebUI\CSRFProtection=false`
})

const data = {
  qb_list,
  fileBrowser,
  qb_service,
  qb_419_conf,
  qb_438_conf
}

export default data