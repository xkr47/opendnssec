$ORIGIN example15.com.     ; designates the start of this zone file in the namespace
$TTL 1h                  ; default expiration time of all resource records without their own TTL value
example15.com.	600	IN	SOA	ns.example15.com. username.example15.com. 2018071300 86400 7200 2419200 300
