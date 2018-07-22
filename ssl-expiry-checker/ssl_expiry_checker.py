#!/usr/bin/env python

'''
Check the expiration of domains and send an alert if any domain
is expiring in 15 days
'''
import socket
import ssl
import datetime
import sys
import json
import logging
import requests

domains = [
   'esc.sh',
   'traversal.in'
]

# Change this to a value you like
THRESHOLD = 15
LOG_FILE = '/var/log/check_ssl_expiry.log'
SLACK_HOOK = 'https://hooks.slack.com/services/xxxxxxxxxxxxxxxxxxx'
SLACK_CHANNEL = '#your-slack-channel'

def get_logger():
    """ Get the logger """
    try:
        logger = logging.getLogger("ssl-checker")
        logger.setLevel(logging.DEBUG)
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        handler = logging.FileHandler(LOG_FILE)
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(formatter)
        logger.addHandler(console_handler)
    except IOError:
        logging.critical("Failed to configure syslog handler.")
        sys.exit(1)
    return logger

def get_expiry_date(domain):
    ''' Get the TLS certificate expiry date for domain '''

    ssl_date_fmt = r'%b %d %H:%M:%S %Y %Z'
    context = ssl.create_default_context()
    try:
        conn = context.wrap_socket(
            socket.socket(socket.AF_INET),
            server_hostname=domain,
        )
    except Exception, err:
        logger.error('Error connecting to domain [%s] : %s', domain, str(err))

    conn.settimeout(5.0)
    conn.connect((domain, 443))
    cert_info = conn.getpeercert()
    date_string = datetime.datetime.strptime(cert_info['notAfter'], ssl_date_fmt)
    return date_string

def send_slack_message(message):
    ''' Send the alerts to slack '''
    headers = {
        'Content-type': 'application/json'
    }
    msg_title = '*SSL Expiry Checker*\n'
    post_data = {
        'channel': SLACK_CHANNEL,
        'text': msg_title + message
    }
    try:
        req = requests.post(SLACK_HOOK, data=json.dumps(post_data), headers=headers)
        if req.status_code == 200:
            logger.info("Sent message to slack")
        else:
            logger.error("Non 200 response received : %s | %s", req.status_code, req.content)
    except Exception, err:
        logger.error("Failed to send message to slack. Exiting | %s", err)


def main():
    ''' The main function '''

    right_now = datetime.datetime.utcnow()
    expiring_domains = {}
    for domain in domains:
        logger.info("Checking domain [%s]", domain)
        expiry = get_expiry_date(domain)
        remaining = expiry - right_now
        if remaining < datetime.timedelta(days=THRESHOLD):
            logger.warning("Domain [%s] is expiring in [%s] days", domain, remaining)
            expiring_domains[domain] = remaining

    if not expiring_domains:
        logger.info("No certs expiring in %s days", THRESHOLD)
    else:
        domains_string = ''
        for key, val in expiring_domains.iteritems():
            temp_string = '\n' + key + ': Expiring in ' + str(val).split(',')[0]
            domains_string += temp_string
        message = "SSL certificate for these domains are expiring in less than %s days %s" % (THRESHOLD, domains_string)
        logger.warning(message)
        send_slack_message(message)

if __name__ == '__main__':
    global logger
    logger = get_logger()
    main()
