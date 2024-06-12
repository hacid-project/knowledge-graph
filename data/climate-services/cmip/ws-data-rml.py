from pyrml import Framework, rml_function, TermUtils
import json
from jsonpath_ng import parse
import pandas as pd
import numpy as np
import glob
import os
from typing import List
from rdflib.term import URIRef, Literal
from slugify import slugify

@rml_function(fun_id='https://w3id.org/hacid/rml-functions/fromList',
              arr='https://w3id.org/hacid/rml-functions/arr',
              ns='https://w3id.org/hacid/rml-functions/ns')

def uri_from_list(arr: str, ns: str) -> List:
    arr = eval(arr)
    for i in range(0, len(arr)):
        v = arr[i]
        arr[i] = URIRef(ns + TermUtils.irify(v))
        
    
    return arr

@rml_function(fun_id='http://users.ugent.be/~bjdmeest/function/grel.ttl#array_get',
              a='http://users.ugent.be/~bjdmeest/function/grel.ttl#p_array_a',
              _from='http://users.ugent.be/~bjdmeest/function/grel.ttl#param_int_i_from',
              to='http://users.ugent.be/~bjdmeest/function/grel.ttl#param_int_i_opt_to'
              )
def get(a: List, _from: int = 0, to: int = None) -> List:
    if not to:
        to = len(a)
    return a[_from:to]

@rml_function(fun_id='https://w3id.org/hacid/rml-functions/simulationIri',
              _id='https://w3id.org/hacid/rml-functions/id',
              _ns='https://w3id.org/hacid/rml-functions/ns')
def simulation_iri(_id: str, _ns: str) -> str:
    
    _id_parts = _id.split('.')
    _id_parts = _id_parts[0:6]
    return _ns + '.'.join(_id_parts[0:6])
    


class CSMapper(object):

    def map_to_rdf(self, homepath: str, jsonpath: str, columns: List, tranpose=True, tpl_vars: dict = None):
        
        json_data = glob.glob(f'{homepath}/data/*.json')[0]
        
        json_data = json.load(open(json_data,mode='r',encoding='utf-8'))
                                
        #jsonpath_expr = parse('$.institution_id')
        jsonpath_expr = parse(jsonpath)
        matches = jsonpath_expr.find(json_data)
        
        data = [match.value for match in matches]
        
        df = pd.json_normalize(data)
        
        
        if tranpose:
            df = df.transpose()
            df = df.reset_index()
            df.columns = columns
        
        #print(df)
        
        
        csv_path = f'{homepath}/data/data.csv'
        df.to_csv(csv_path)
        
        
        mapper = Framework.get_mapper()
        
        vars = {'CSV': csv_path}
        
        if tpl_vars:
            vars.update(tpl_vars)
        
        rml_path = glob.glob(f'{homepath}/rml/*.ttl')[0]
        
        rdf_path = f'{homepath}/rdf/data.ttl'
        out = mapper.convert(rml_path, False, vars)
        out.serialize(rdf_path, format='text/turtle')
        
        mapper.reset()

if __name__ == '__main__':
    homepath = '.'
    subfolders = [ f.path for f in os.scandir(homepath) if f.is_dir() ]
    
    cs_mapper = CSMapper()
    
    for subfolder in subfolders:
        if subfolder.endswith('cmip5'):
            conf = f'{subfolder}/conf.json'
            json_conf = json.load(open(conf,mode='r',encoding='utf-8'))
            jsonpath = json_conf['jsonpath']
            columns = json_conf['columns']
            transpose = json_conf['transpose'] if 'transpose' in json_conf else True
            
            if 'vars' in json_conf:
                _vars = json_conf['vars']
            else:
                _vars = None
                
            cs_mapper.map_to_rdf(subfolder, jsonpath, columns, transpose, _vars)
    
