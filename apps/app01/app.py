#!/usr/bin/env python3
from flask import Flask, request, render_template, abort

from datetime import datetime
import json
import logging
import logging.config
import os
import requests

import db_client
import db_client_transform


dbc = None
vclient = None

log_level = {
  'CRITICAL': 50,
  'ERROR': 40,
  'WARN': 30,
  'INFO': 20,
  'DEBUG': 10
}

logger = logging.getLogger('app')

app = Flask(__name__)
app.config['TEMPLATES_AUTO_RELOAD'] = True


@app.route('/customers', methods=['GET'])
def get_customers():
    global dbc
    customers = dbc.get_customer_records()
    logger.debug('Customers: {}'.format(customers))
    return json.dumps(customers)


@app.route('/customer', methods=['GET'])
def get_customer():
    global dbc
    cust_no = request.args.get('cust_no')
    if not cust_no:
        return '<html><body>Error: cust_no is a required argument for the customer endpoint.</body></html>', 500
    record = dbc.get_customer_record(cust_no)
    # logger.debug('Request: {}'.format(request))
    return json.dumps(record)


@app.route('/customers', methods=['POST'])
def create_customer():
    global dbc
    logging.debug("Form Data: {}".format(dict(request.form)))
    customer = {k: v for (k, v) in dict(request.form).items()}
    for k, v in customer.items():
        if type(v) is list:
            customer[k] = v[0]
    logging.debug('Customer: {}'.format(customer))
    if 'create_date' not in customer.keys():
        customer['create_date'] = datetime.now().isoformat()
    new_record = dbc.insert_customer_record(customer)
    logging.debug('New Record: {}'.format(new_record))
    return json.dumps(new_record)


@app.route('/customers', methods=['PUT'])
def update_customer():
    global dbc
    logging.debug('Form Data: {}'.format(dict(request.form)))
    customer = {k: v for (k, v) in dict(request.form).items()}
    for k, v in customer.items():
        if type(v) is list:
            customer[k] = v[0]
    logging.debug('Customer: {}'.format(customer))
    new_record = dbc.update_customer_record(customer)
    logging.debug('New Record: {}'.format(new_record))
    return json.dumps(new_record)


@app.route('/', methods=['GET'])
def index():
    return render_template('index.html')


@app.route('/records', methods=['GET'])
def records():
    records = json.loads(get_customers())
    return render_template('records.html', results=records)


@app.route('/dbview', methods=['GET'])
def dbview():
    global dbc
    records = dbc.get_customer_records(raw=True)
    return render_template('dbview.html', results=records)


@app.route('/add', methods=['GET'])
def add():
    return render_template('add.html')


@app.route('/add', methods=['POST'])
def add_submit():
    records = create_customer()
    return render_template('records.html', results=json.loads(records), record_added=True)


@app.route('/update', methods=['GET'])
def update():
    return render_template('update.html')


@app.route('/update', methods=['POST'])
def update_submit():
    records = update_customer()
    return render_template('records.html', results=json.loads(records), record_updated=True)


if __name__ == '__main__':
    logger.warning('In Main...')

    logging.basicConfig(
      level=log_level['DEBUG'],
      format='%(asctime)s - %(levelname)8s - %(name)9s - %(funcName)15s - %(message)s'
    )

    try:
        vault_address = os.environ["VAULT_ADDR"]
        vault_namespace = os.environ["VAULT_NAMESPACE"]
        vault_transit_path = os.environ["VAULT_TRANSIT_PATH"]
        vault_transform_path = os.environ["VAULT_TRANSFORM_PATH"]
        vault_transform_masking_path = os.environ["VAULT_TRANSFORM_MASKING_PATH"]
        vault_database_creds_path = os.environ["VAULT_DATABASE_CREDS_PATH"]
        database_address = os.environ["MYSQL_ADDR"]
        vault_transform_enabled = True

        dbc = db_client.DbClient()

        if vault_transform_enabled:
            logger.info('Using Transform database client...')
            try:
                dbc = db_client_transform.DbClient()
            except Exception as e:
                logging.error("There was an error starting the server: {}".format(e))

        dbc.init_vault(addr=vault_address, namespace=vault_namespace, path=vault_transit_path, key_name="customer-key", transform_path=vault_transform_path, transform_masking_path=vault_transform_masking_path)

        logger.debug('db_auth')
        dbc.vault_db_auth(vault_database_creds_path)
        dbc.init_db(uri=database_address,
                    prt="3306",
                    uname=dbc.username,
                    pw=dbc.password,
                    db="my_app"
                    )

        # seed records
        record = {'customer_number': '2', 'first_name': 'Larry', 'last_name': 'Johnson', 'birth_date': '3/14/1969', 'ssn': '222-22-2222', 'ccn': '3600-5600-6750-0000', 'address': 'Tyler, Texas', 'salary': '7000000', 'create_date': "2020-01-01T14:49:12.301977"}
        dbc.insert_customer_record(record)

        record = {'customer_number': '34', 'first_name': 'Shawn', 'last_name': 'Kemp', 'birth_date': '11/26/1969', 'ssn': '333-34-4444', 'ccn': '2350-3200-8091-0001', 'address': 'Elkhart, Indiana', 'salary': '15000000', 'create_date': "2020-02-21T10:24:55.985726"}
        dbc.insert_customer_record(record)

        record = {'customer_number': '40', 'first_name': 'Charles', 'last_name': 'Barkley', 'birth_date': '2/20/1963', 'ssn': '444-00-4040', 'ccn': '5310-7200-1553-0002', 'address': 'Leeds, Alabama', 'salary': '9000000', 'create_date': "2019-04-09T01:10:20.548144"}
        dbc.insert_customer_record(record)

        logger.info('Starting Flask server on {} listening on port {}'.format('0.0.0.0', '5000'))
        app.run(host='0.0.0.0', port=5000)

    except Exception as e:
        logging.error("There was an error starting the server: {}".format(e))
