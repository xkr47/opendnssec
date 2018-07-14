$ORIGIN example5.com.     ; designates the start of this zone file in the namespace
$TTL 1h                  ; default expiration time of all resource records without their own TTL value
example5.com.	600	IN	SOA	ns.example5.com. username.example5.com. 2018071300 86400 7200 2419200 300
