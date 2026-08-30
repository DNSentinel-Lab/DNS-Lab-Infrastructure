# Scenario 04 — Infrastructure Command Ledger

This is a cleaned implementation ledger, not a transcript. It preserves the commands that materially built or validated the Scenario 04 authoritative DNS path.

## Package installation and service validation

```bash
apt update
apt install -y bind9 bind9-utils dnsutils
systemctl status named --no-pager
named -v
```

## Back up and apply authoritative-only options

```bash
cp /etc/bind/named.conf.options /etc/bind/named.conf.options.backup

cat > /etc/bind/named.conf.options <<'EOF'
options {
        directory "/var/cache/bind";

        recursion no;
        allow-query { any; };

        listen-on { any; };
        listen-on-v6 { none; };

        dnssec-validation auto;
};
EOF

named-checkconf
systemctl restart named
systemctl status named --no-pager
```

## IPv4-only authoritative cleanup

The initial authoritative-only service still attempted unnecessary outbound IPv6/DNSSEC work. The final authoritative host was narrowed further:

```bash
cat > /etc/default/named <<'EOF'
OPTIONS="-4 -u bind"
EOF

sed -i 's/dnssec-validation auto;/dnssec-validation no;/' /etc/bind/named.conf.options

named-checkconf
systemctl restart named
systemctl status named --no-pager
journalctl -u named -n 15 --no-pager
```

The final repository-safe versions of these files are stored in `bind/`.

## Create the authoritative zone

```bash
cat >> /etc/bind/named.conf.local <<'EOF'

zone "tunnel.soclab.abdul4rehman215.tech" {
        type master;
        file "/etc/bind/db.tunnel.soclab";
        allow-transfer { none; };
};
EOF

cat > /etc/bind/db.tunnel.soclab <<'EOF'
$TTL 60

@   IN  SOA ns1.tunnel.soclab.abdul4rehman215.tech. admin.tunnel.soclab.abdul4rehman215.tech. (
        2026082901
        300
        120
        604800
        60
)

    IN  NS  ns1.tunnel.soclab.abdul4rehman215.tech.

ns1 IN  A   98.93.89.38
@   IN  A   98.93.89.38
*   IN  A   98.93.89.38
EOF
```

## Zone validation

```bash
named-checkconf
named-checkzone tunnel.soclab.abdul4rehman215.tech /etc/bind/db.tunnel.soclab
systemctl restart named
systemctl status named --no-pager
```

## Local authoritative tests

```bash
dig @127.0.0.1 tunnel.soclab.abdul4rehman215.tech A
dig @127.0.0.1 test123.tunnel.soclab.abdul4rehman215.tech A
```

The first query validated the zone apex. The second validated the wildcard required for fresh unique labels.

## Query-log configuration and validation

```bash
mkdir -p /var/log/named
chown bind:bind /var/log/named
chmod 750 /var/log/named

cat >> /etc/bind/named.conf.local <<'EOF'

logging {
    channel scenario04_queries {
        file "/var/log/named/scenario04-queries.log" versions 5 size 10m;
        severity info;
        print-time yes;
        print-category yes;
        print-severity yes;
    };

    category queries {
        scenario04_queries;
    };
};
EOF

named-checkconf
systemctl restart named
systemctl status named --no-pager

dig @127.0.0.1 loggingtest.tunnel.soclab.abdul4rehman215.tech A
tail -n 10 /var/log/named/scenario04-queries.log
```

## Public delegation validation

```bash
dig tunnel.soclab.abdul4rehman215.tech NS
dig ns1.tunnel.soclab.abdul4rehman215.tech A
dig publictest.tunnel.soclab.abdul4rehman215.tech A
```

## Victim resolver-path validation

On `dns-soc-victim01`:

```bash
resolvectl status
dig victimtest.tunnel.soclab.abdul4rehman215.tech A
```

The victim remained on its normal defender-controlled DNS path through `10.50.30.10`.

On `dns-soc-resolver01`:

```bash
grep -RniE 'logfile:|use-syslog:|verbosity:' /etc/unbound/ 2>/dev/null
journalctl -u unbound --since "15 minutes ago" --no-pager \
  | grep "victimtest.tunnel.soclab.abdul4rehman215.tech"
```

On `dns-tunnel-auth01`:

```bash
grep "victimtest.tunnel.soclab.abdul4rehman215.tech" \
  /var/log/named/scenario04-queries.log | tail -n 10
```

## Fresh-label smoke test

On the victim:

```bash
dig s04smoke01.tunnel.soclab.abdul4rehman215.tech A
dig s04smoke02.tunnel.soclab.abdul4rehman215.tech A
dig s04smoke03.tunnel.soclab.abdul4rehman215.tech A
```

On the authoritative host:

```bash
grep "s04smoke" /var/log/named/scenario04-queries.log
```

The three unique names were received by the authoritative endpoint, proving the infrastructure can carry the fresh-subdomain behavior needed for later controlled tunneling-pattern tests.
