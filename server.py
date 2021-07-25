import os
from urllib import parse
from bson import json_util
from dotenv import load_dotenv
from flask_pymongo import PyMongo
from flask import Flask, jsonify, request, json

app = Flask(__name__)
load_dotenv()
# connect to MongoDB with the first_database
mongo1 = PyMongo(app, uri="mongodb://read:{}@{}:27017/first_database".format(parse.quote(os.environ.get("READ_PASSWORD")), "localhost"))

# connect to MongoDB with the first_database
mongo2 = PyMongo(app, uri="mongodb://readWrite:{}@{}:27017/second_database".format(parse.quote(os.environ.get("READ_WRITE_PASSWORD")), "localhost"))


@app.route("/", methods=["GET"])
def home():
    return jsonify("Hello World!")

@app.route("/api", methods=["GET"])
def response_data():
    try:
        users = mongo1.db.users.find({})
        users_json = [
            {
                **user,
                "_id": str(user["_id"])
            } for user in users
        ]
        products = mongo2.db.products.find({})
        products_json = [
            {
                **product,
                "_id": str(product["_id"])
            } for product in products
        ]
        return jsonify(
            users_from_first_database=users_json, products_from_second_database=products_json
        )
    except Exception as error:
        return jsonify(
            message="API Failed"
        )

@app.route("/api/add/user", methods=["POST"])
def insert_user_data():
    try:
        body = request.get_json()
        user_id = mongo1.db.users.insert_one({
            **body
        }).inserted_id
        return jsonify(
            message="user added",
            user_id=str(user_id)
         )
    except Exception as error:
        return jsonify(
            message="Cannot add user due to lack of write permission"
        )

@app.route("/api/add/product", methods=["POST"])
def insert_product_data():
    try:
        body = request.get_json()
        product_id = mongo2.db.products.insert_one({
            **body
        }).inserted_id
        return jsonify(
            message="product added",
            product_id=str(product_id)
         )    
    except Exception as error:
        return jsonify(
            message="API Failed"
        )