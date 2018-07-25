$ORIGIN example47.com.     ; designates the start of this zone file in the namespace
$TTL 1h                  ; default expiration time of all resource records without their own TTL value
example47.com.	600	IN	SOA	ns.example47.com. username.example47.com. 2018071300 86400 7200 2419200 300
