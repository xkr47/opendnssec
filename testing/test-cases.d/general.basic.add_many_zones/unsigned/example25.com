$ORIGIN example25.com.     ; designates the start of this zone file in the namespace
$TTL 1h                  ; default expiration time of all resource records without their own TTL value
example25.com.	600	IN	SOA	ns.example25.com. username.example25.com. 2018071300 86400 7200 2419200 300
