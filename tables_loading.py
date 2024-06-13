
import pandas as pd 
from sqlalchemy import create_engine

conn_string = 'postgresql://postgres:7597@localhost/paintings_case_study'
db = create_engine(conn_string)
conn = db.connect()

files = ['artist', 'canvas_size', 'image_link', 'museum_hours', 'product_size', 'subject', 'work', 'museum']

for file in files:
    df=pd.read_csv(f'/Users/rajpetlu/Downloads/SQL Paintings case study/{file}.csv')
    df.to_sql(file, con=conn, if_exists='replace', index=False)