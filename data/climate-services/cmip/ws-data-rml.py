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

scenario_map = {
    'rcp45': 'https://w3id.org/hacid/data/greenhousegasconcentrationpathway/rcp-4.5',
    'rcp85': 'https://w3id.org/hacid/data/greenhousegasconcentrationpathway/rcp-8.5',
    'rcp26': 'https://w3id.org/hacid/data/greenhousegasconcentrationpathway/rcp-2.6',
    'rcp60': 'https://w3id.org/hacid/data/greenhousegasconcentrationpathway/rcp-6'
    }

@rml_function(fun_id='https://w3id.org/hacid/rml-functions/fromList',
              arr='https://w3id.org/hacid/rml-functions/arr',
              ns='https://w3id.org/hacid/rml-functions/ns')

def uri_from_list(arr: str, ns: str) -> List:
    arr = eval(arr)
    i = 0
    for s in arr:
        arr[i] = URIRef(ns + TermUtils.irify(s))
        i += 1
        
    
    return arr

@rml_function(fun_id='https://w3id.org/hacid/rml-functions/eval',
              _str='https://w3id.org/hacid/rml-functions/str')
def _eval(_str: str) -> object:
    return eval(_str)

@rml_function(fun_id='http://users.ugent.be/~bjdmeest/function/grel.ttl#array_get',
              a='http://users.ugent.be/~bjdmeest/function/grel.ttl#p_array_a',
              _from='http://users.ugent.be/~bjdmeest/function/grel.ttl#param_int_i_from',
              to='http://users.ugent.be/~bjdmeest/function/grel.ttl#param_int_i_opt_to'
              )
def get(a: List, _from: int = 0, to: int = None) -> List:

    if not to:
        to = len(a)
    return a[_from:to]
    
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/geti',
              a='https://w3id.org/hacid/rml-functions/array',
              index='https://w3id.org/hacid/rml-functions/index')
def get_i(a: List, index: int) -> object:

    return a[index]
    
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/getScenario',
              scenario='https://w3id.org/hacid/rml-functions/scenario')
def get_scenario(scenario: str) -> str:
    scenario = str(scenario)
    if scenario in scenario_map:
        return scenario_map[scenario]
    else:
        return None

@rml_function(fun_id='https://w3id.org/hacid/rml-functions/cmip5DatasetId',
              _id='https://w3id.org/hacid/rml-functions/id')
def cmip5_dataset_id(_id: str) -> str:
    _id_parts = _id.split('|')[0].split('.')
    return '.'.join(_id_parts[:-1])
    
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/cmip5DatasetIri',
              _id='https://w3id.org/hacid/rml-functions/id',
              _ns='https://w3id.org/hacid/rml-functions/ns')
def cmip5_dataset_iri(_id: str, _ns: str) -> str:
    return _ns + cmip5_dataset_id(_id)
    
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/cmip5SimulationId',
              _id='https://w3id.org/hacid/rml-functions/id')
def cmip5_simulation_id(_id: str) -> str:
    #template "cmip5.%(product)s.%(institute)s.%(model)s.%(experiment)s.%(time_frequency)s.%(realm)s.%(cmor_table)s.%(ensemble)s"
    _id_parts = _id.split('|')[0].split('.')
    _model= _id_parts[3]
    _experiment = _id_parts[4]
    return '.'.join(['cmip5', _model, _experiment])
    
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/cmip5SimulationIri',
              _id='https://w3id.org/hacid/rml-functions/id',
              _ns='https://w3id.org/hacid/rml-functions/ns')
def cmip5_simulation_iri(_id: str, _ns: str) -> str:
    return _ns + cmip5_simulation_id(_id)
    
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/cordexDatasetId',
              _id='https://w3id.org/hacid/rml-functions/id')
def cmip5_cordex_dataset_id(_id: str) -> str:
    _id_parts = _id.split('|')[0].split('.')
    return '.'.join(_id_parts[:-1])
    
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/cordexDatasetIri',
              _id='https://w3id.org/hacid/rml-functions/id',
              _ns='https://w3id.org/hacid/rml-functions/ns')
def cmip5_cordex_dataset_iri(_id: str, _ns: str) -> str:
    return _ns + cmip5_cordex_dataset_id(_id)

@rml_function(fun_id='https://w3id.org/hacid/rml-functions/cordexSimulationId',
              _id='https://w3id.org/hacid/rml-functions/id')
def cordex_simulation_id(_id: str) -> str:
    # template "cordex.%(product)s.%(domain)s.%(institute)s.%(driving_model)s.%(experiment)s.%(ensemble)s.%(rcm_name)s.%(rcm_version)s.%(time_frequency)s.%(variable)s"
    _id_parts = _id.split('|')[0].split('.')
    _domain= _id_parts[2]
    _driving_model= _id_parts[4]
    _experiment= _id_parts[5]
    _model = _id_parts[7]
    _model_version = _id_parts[8]
    return '.'.join([
        'cordex',
        _domain, _driving_model, _experiment,
        _model, _model_version
    ])
    
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/cordexSimulationIri',
              _id='https://w3id.org/hacid/rml-functions/id',
              _ns='https://w3id.org/hacid/rml-functions/ns')
def cordex_simulation_iri(_id: str, _ns: str) -> str:
    return _ns + cordex_simulation_id(_id)
    
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/cordexDrivingSimulationIri',
              _id='https://w3id.org/hacid/rml-functions/id',
              _ns='https://w3id.org/hacid/rml-functions/ns')
def cordex_driving_simulation_iri(_id: str, _ns: str) -> str:
    # template "cordex.%(product)s.%(domain)s.%(institute)s.%(driving_model)s.%(experiment)s.%(ensemble)s.%(rcm_name)s.%(rcm_version)s.%(time_frequency)s.%(variable)s"
    _id_parts = _id.split('.')
    _driving_model= _id_parts[4]
    _experiment= _id_parts[5]
    return _ns + '.'.join([
        'cmip5',
         _driving_model, _experiment
    ])
    


class CSMapper(object):

    def map_to_rdf(self, homepath: str, jsonpath: str, columns: List, tranpose=True, tpl_vars: dict = None):
        
        def map_file_to_rdf(input_json_filename: str, file_count: int | None = None):
            
            filename_suffix = (
                f'-{file_count}'
                if file_count is not None
                else ''
            )
            
            json_data = json.load(open(input_json_filename,mode='r',encoding='utf-8'))
                                    
            #jsonpath_expr = parse('$.institution_id')
            jsonpath_expr = parse(jsonpath)
            matches = jsonpath_expr.find(json_data)
            
            data = [match.value for match in matches]
            
            df = pd.json_normalize(data)

            if tranpose:
                df = df.transpose()
                df = df.reset_index()
                df.columns = columns #.copy()

            csv_path = f'{homepath}/data/data{filename_suffix}.csv'
            df.to_csv(csv_path)
            
            
            mapper = Framework.get_mapper()
            
            vars = {'CSV': csv_path}
            
            if tpl_vars:
                vars.update(tpl_vars)
            
            rml_path = glob.glob(f'{homepath}/rml/*.ttl')[0]
            
            rdf_path = f'{homepath}/rdf/data{filename_suffix}.ttl'
            out = mapper.convert(rml_path, False, vars)
            out.serialize(rdf_path, format='text/turtle')
            
            mapper.reset()

        filenames = glob.glob(f'{homepath}/data/*.json')
        if len(filenames) > 1:
            for file_index, filename in enumerate(glob.glob(f'{homepath}/data/*.json')):
                print(f'{file_index}: {filename}')
                map_file_to_rdf(input_json_filename=filename, file_count=file_index)
        elif len(filenames) == 1:
            map_file_to_rdf(input_json_filename=filenames[0])

if __name__ == '__main__':
    homepath = '.'
    subfolders = [ f.path for f in os.scandir(homepath) if f.is_dir() ]
    
    cs_mapper = CSMapper()
    
    for subfolder in subfolders:
        if subfolder.endswith('cordex') or subfolder.endswith('cmip5'):
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
    
