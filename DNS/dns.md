# DNS[$^{1}$][cloudflare_doc]$^{,}$[$^{2}$][fp_doc]

## Table of content

* [Definition](#definition)
* [Types of DNS servers](#types-of-dns-servers)
* [DNS Functioning](#dns-functioning)
* [Types of DNS queries](#types-of-dns-queries)
* [DNS Caching](#dns-caching)
  * [Browser DNS Caching](#browser-dns-caching)
  * [Operating system (OS) level DNS Caching](#operating-system-os-level-dns-caching)
* [DNS Records](#dns-records)
  * [Most common types of DNS record](#most-common-types-of-dns-record)
  * [Least common types of DNS record](#least-common-types-of-dns-record)
* [Reverse DNS](#reverse-dns)
  * [Reverse DNS Functioning](#reverse-dns-functioning)
* [DNS zone](#dns-zone)
  * [DNS zone file](#dns-zone-file)
  * [Reverse Lookup Zone](#reverse-lookup-zone)
* [DNS Forwarding Zone](#dns-forwarding-zone)
* [DNS Troubleshooting Tools](#dns-troubleshooting-tools)
  * [Command tools](#command-tools)
  * [Website tools](#website-tools)

## Definition

DNS (Domain Name System) is a system based on several types of servers chained together that translates domain names such as `example.com` to their associated IP address.

This is useful since humans can remind word based names better than IP addresses.

## Types of DNS servers

There are 4 types of server involved in the IP address resolution:

* **DNS Recursor** - It receives queries from client machines and is responsible for making additional requests in order to satisfy the client's DNS query.

* **Root Nameserver** - It hosts the adresses of **Top Level Domain (TLD) DNS servers** (such as `.com` or `.io`) and is the first step in traslating the domain name.

* **TLD Nameserver** - It hosts the last portion of a hostname. In `example.com`, the TLD server is "`com`". It is the next step in the seek for a specific IP address.

* **Authoritative Nameserver** - It hosts the IP address for the requested hostname. It's the final step in the nmeserver query.

## DNS Functioning

1. User searches for `example.com`. This query travels through Internet up to a **DNS recursive resolver**.

2. The **resolver** queries a **DNS root nameserver**.

3. The **root server** responds to the *resolver* with the address of a **TLD DNS server**, which stores the information for its domains. In ***this*** search, the request is pointed toward **`.com` TLD**.

4. The **resolver** makes a request to the **`.com` TLD**.

5. The **TLD server** then responds with IP address of the **domain's nameserver**, `example.com`.

6. Lastly, the **recursive resolver** sends a query to the **domain's nameserver**.

7. The IP address for `example.com` is returned to the **resolver** from the **nameserver**.

8. The **DNS resolver** responds to the client machine with the IP address of the domain requested initially (`example.com`).

## Types of DNS queries

* **Recursive query** -  In a recursive query, a DNS client requires that a DNS server (typically a DNS recursive resolver) will respond to the client with either the requested resource record or an error message if the resolver can't find the record.

* **Iterative query** - in this situation the DNS client will allow a DNS server to return the best answer it can. If the queried DNS server does not have a match for the query name, it will return a referral to a DNS server authoritative for a lower level of the domain namespace. The DNS client will then make a query to the referral address. This process continues with additional DNS servers down the query chain until either an error or timeout occurs.

* **Non-recursive query** - typically this will occur when a DNS resolver client queries a DNS server for a record that it has access to either because it's authoritative for the record or the record exists inside of its cache. Typically, a DNS server will cache DNS records to prevent additional bandwidth consumption and load on upstream servers.

## DNS Caching

The purpose of caching is to temporarily stored data in a location that results in improvements in performance and reliability for data requests. DNS caching involves storing data closer to the requesting client so that the DNS query can be resolved earlier and additional queries further down the DNS lookup chain can be avoided, thereby improving load times and reducing bandwidth/CPU consumption. DNS data can be cached in a variety of locations, each of which will store DNS records for a set amount of time determined by a **time-to-live (`TTL`).**

### Browser DNS Caching

Modern web browsers are designed by default to cache DNS records for a set amount of time.
When a request is made for a DNS record, the browser cache is the first location checkedfor the requested record.

### Operating system (OS) level DNS Caching

The operating system level DNS resolver is the second and last local stop before a DNS query leaves your machine. The process inside your operating system that is designed to handle this query is commonly called a *“stub resolver”* or DNS client. When a stub resolver gets a request from an application, it first checks its own cache to see if it has the record. If it does not, it then sends a DNS query (with a recursive flag set), outside the local network to a DNS recursive resolver inside the Internet service provider (ISP).

When the recursive resolver inside the ISP receives a DNS query, like all previous steps, it will also check to see if the requested host-to-IP-address translation is already stored inside its local persistence layer.

The recursive resolver also has additional functionality depending on the types of records it has in its cache:

1. If the resolver does not have the A records, but does have the NS records for the authoritative nameservers, it will query those name servers directly, bypassing several steps in the DNS query. This shortcut prevents lookups from the root and `.com` nameservers (in our search for `example.com`) and helps the resolution of the DNS query occur more quickly.

2. If the resolver does not have the NS records, it will send a query to the TLD servers (`.com` in our case), skipping the root server.

3. In the unlikely event that the resolver does not have records pointing to the TLD servers, it will then query the root servers. This event typically occurs after a DNS cache has been purged.

## DNS Records

DNS records (aka zone files) are instructions that live in authoritative DNS servers and provide information about a domain including what IP address is associated with that domain and how to handle requests for that domain. These records consist of a series of text files written in what is known as DNS syntax. DNS syntax is just a string of characters used as commands that tell the DNS server what to do. All DNS records also have a ‘TTL’, which stands for time-to-live, and indicates how often a DNS server will refresh that record.

All domains are required to have at least a few essential DNS records for a user to be able to access their website using a domain name, and there are several optional records that serve additional purposes.

### Most common types of DNS record

* **A record**[$^{+}$][a_record_doc] - The record that holds the IPv4 address of a domain.
* **AAAA record**[$^{+}$][aaaa_record_doc] - The record that contains the IPv6 for a domain.
* **CNAME record**[$^{+}$][cname_record_doc] - Forwards one domain or subdomain to another domain, but does **NOT** provide an IP address.
* **MX record**[$^{+}$][mx_record_doc] - Directs mail to an email server.
* **TXT record**[$^{+}$][txt_record_doc] - Lets an admin store text notes in the record. These records are often used for email security.
* **NS record**[$^{+}$][ns_record_doc] - Stores admin information about a domain.
* **SOA record**[$^{+}$][soa_record_doc] - Stores admin information about a domain.
* **SRV record**[$^{+}$][srv_record_doc] - Specifies a port for specific services.
* **PTR record**[$^{+}$][ptr_record_doc] - Provides a domain name in reverse-lookups.

### Least common types of DNS record

* **AFSDB record** - This record is used for clients of the Andrew File System (AFS) developed by Carnegie Melon. The AFSDB record functions to find other AFS cells.

* **APL record** - The ‘address prefix list’ is an experiment record that specifies lists of address ranges.

* **CAA record** - This is the ‘certification authority authorization’ record, it allows domain owners state which certificate authorities can issue certificates for that domain. If no CAA record exists, then anyone can issue a certificate for the domain. These records are also inherited by subdomains.

* **DNSKEY record** - The ‘DNS Key Record’ contains a public key used to verify Domain Name System Security Extension (DNSSEC) signatures.

* **CDNSKEY record** - This is a child copy of the DNSKEY record, meant to be transferred to a parent.

* **CERT record** - The ‘certificate record’ stores public key certificates.

* **DCHID record** - The ‘DHCP Identifier’ stores info for the Dynamic Host Configuration Protocol (DHCP), a standardized network protocol used on IP networks.

* **DNAME record** - The ‘delegation name’ record creates a domain alias, just like CNAME, but this alias will redirect all subdomains as well. For instance if the owner of ‘example.com’ bought the domain ‘website.net’ and gave it a DNAME record that points to ‘example.com’, then that pointer would also extend to ‘blog.website.net’ and any other subdomains.

* **HIP record** - This record uses ‘Host identity protocol’, a way to separate the roles of an IP address; this record is used most often in mobile computing.

* **IPSECKEY record** - The ‘IPSEC key’ record works with the Internet Protocol Security (IPSEC), an end-to-end security protocol framework and part of the Internet Protocol Suite (TCP/IP).

* **LOC record** - The ‘location’ record contains geographical information for a domain in the form of longitude and latitude coordinates.

* **NAPTR record** - The ‘name authority pointer’ record can be combined with an SRV record to dynamically create URI’s to point to based on a regular expression.

* **NSEC record** - The ‘next secure record’ is part of DNSSEC, and it’s used to prove that a requested DNS resource record does not exist.

* **RRSIG record** - The ‘resource record signature’ is a record to store digital signatures used to authenticate records in accordance with DNSSEC.

* **RP record** - This is the ‘responsible person’ record and it stores the email address of the person responsible for the domain.

* **SSHFP record** - This record stores the ‘SSH public key fingerprints’; SSH stands for Secure Shell and it’s a cryptographic networking protocol for secure communication over an unsecure network.

## Reverse DNS

A reverse DNS lookup is a DNS query for the domain name associated with a given IP address. This accomplishes the opposite of the more commonly used forward DNS lookup, in which the DNS system is queried to return an IP address.

Standards from the Internet Engineering Task Force (IETF) suggest that every domain should be capable of reverse DNS lookup, but as reverse lookups are not critical to the normal function of the Internet, they are not a hard requirement. As such, reverse DNS lookups are not universally adopted.

Reverse lookups are commonly used by email servers. Email servers check and see if an email message came from a valid server before bringing it onto their network. Many email servers will reject messages from any server that does not support reverse lookups or from a server that is highly unlikely to be legitimate. Spammers often use IP addresses from hijacked machines, which means there will be no PTR record. Or, they may use dynamically assigned IP addresses that lead to server domains with highly generic names.

Logging software also employs reverse lookups in order to provide users with human-readable domains in their log data, as opposed to a bunch of numeric IP addresses.

### Reverse DNS Functioning

Reverse DNS lookups query DNS servers for a PTR (pointer) record; if the server does not have a PTR record, it cannot resolve a reverse lookup. PTR records store IP addresses with their segments reversed, and they append ".in-addr.arpa" to that. For example if a domain has an IP address of 192.0.2.1, the PTR record will store the domain's information under 1.2.0.192.in-addr.arpa.

In IPv6, the latest version of the Internet Protocol, PTR records are stored within the ".ip6.arpa" domain instead of ".in-addr.arpa."

## DNS zone [$^{+}$][dns_zone_doc]

The DNS is broken up into many different zones. These zones differentiate between distinctly managed areas in the DNS namespace. A DNS zone is a portion of the DNS namespace that is managed by a specific organization or administrator. A DNS zone is an administrative space which allows for more granular control of DNS components, such as authoritative nameservers. The domain name space is a hierarchical tree, with the DNS root domain at the top. A DNS zone starts at a domain within the tree and can also extend down into subdomains so that multiple subdomains can be managed by one entity.

A common mistake is to associate a DNS zone with a domain name or a single DNS server. In fact, a DNS zone can contain multiple subdomains and multiple zones can exist on the same server. DNS zones are not necessarily physically separated from one another, zones are strictly used for delegating control.

### DNS zone file

A zone file is a plain text file stored in a DNS server that contains an actual representation of the zone and contains all the records for every domain within the zone. Zone files must always start with a [Start of Authority (SOA) record][soa_record_doc], which contains important information including contact information for the zone administrator.

### Reverse Lookup Zone

A [reverse lookup][reverse_dns] zone contains mapping from an IP address to the host (the opposite function of most DNS zones). These zones are used for troubleshooting, spam filtering, and bot detection.

## DNS Forwarding Zone

A forwarding DNS server has a cache to store previous responses and so improve future duplicated queries.

If the requested query can not be resolved with the data in this cache, then the DNS Forwarding server redirects the query to an external DNS server which is in fact responsible to resolve the query.

Note that the Forwarding Server **DOES NOT** do recursive queries, it just delegates this to another DNS zone.

This type of DNS server is quite useful when access to an external network is slow, expensive or saturated.

## DNS Troubleshooting Tools

### Command tools

* **nslookup**[$^{+}$][nslookup_doc] - Windows and Linux utily. **(RECOMMENDED)**

* **dig**[$^{+}$][dig_doc] - Linux utility.

* **host**[$^{+}$][host_doc] - Linux utility.

* **whois**[$^{+}$][whois_doc] - Linux utility.

### Website tools

* [**intoDNS**][intodns_site] **(RECOMMENDED)**

* [**DNS Spy**][dnsspy_site]

* [**MX Toolbox**][mxtoolbox_site] - Quite useful to check mail services' health and configuration problems.

* [**DNSquery**][dnsquery_site] - Bunch of tools in the same webpage.

[//]: # (LINK LABELS)

[//]: # (GENERAL DOC LINK)
[cloudflare_doc]: https://www.cloudflare.com/en-gb/learning/dns/what-is-dns/
[fp_doc]: https://www.fpgenred.es/DNS/_cmo_funciona_.html
[dns_zone_doc]: https://www.cloudflare.com/en-gb/learning/dns/glossary/dns-zone/

[//]: # (TROUBLESHOOTING LINKS)
[nslookup_doc]: https://linux.die.net/man/1/nslookup
[dig_doc]: https://linux.die.net/man/1/dig
[host_doc]: https://linux.die.net/man/1/host
[whois_doc]: https://linux.die.net/man/1/whois
[dnsspy_site]: https://dnsspy.io/
[intodns_site]: https://intodns.com/
[mxtoolbox_site]: https://mxtoolbox.com/
[dnsquery_site]: https://dnsquery.org/

[//]: # (DNS RECORDS LINKS)
[a_record_doc]: https://www.cloudflare.com/learning/dns/dns-records/dns-a-record/
[aaaa_record_doc]: https://www.cloudflare.com/learning/dns/dns-records/dns-aaaa-record/
[cname_record_doc]: https://www.cloudflare.com/learning/dns/dns-records/dns-cname-record/
[mx_record_doc]: https://www.cloudflare.com/learning/dns/dns-records/dns-mx-record/
[txt_record_doc]: https://www.cloudflare.com/learning/dns/dns-records/dns-txt-record/
[ns_record_doc]: https://www.cloudflare.com/learning/dns/dns-records/dns-ns-record/
[soa_record_doc]: https://www.cloudflare.com/learning/dns/dns-records/dns-soa-record/
[srv_record_doc]: https://www.cloudflare.com/learning/dns/dns-records/dns-soa-record/
[ptr_record_doc]: https://www.cloudflare.com/learning/dns/dns-records/dns-ptr-record/

[//]: # (IN-DOCUMENT LINKS)
[reverse_dns]: #reverse-dns
