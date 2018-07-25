$ORIGIN example75.com.     ; designates the start of this zone file in the namespace
$TTL 1h                  ; default expiration time of all resource records without their own TTL value
example75.com.	600	IN	SOA	ns.example75.com. username.example75.com. 2018071300 86400 7200 2419200 300
