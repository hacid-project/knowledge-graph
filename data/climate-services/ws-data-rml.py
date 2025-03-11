import re
import string
from pyrml import Framework, rml_function, TermUtils
import json
from jsonpath_ng import parse
import pandas as pd
import numpy as np
import glob
import os
from typing import List
from rdflib.term import URIRef, Literal
import shortuuid
from slugify import slugify
from typing import Literal
from datetime import datetime, timedelta, timezone
from dateutil.relativedelta import relativedelta
from dateutil.parser import isoparse
from urllib.parse import quote

scenario_map = {
    'rcp45': 'https://w3id.org/hacid/data/greenhousegasconcentrationpathway/rcp-4.5',
    'rcp85': 'https://w3id.org/hacid/data/greenhousegasconcentrationpathway/rcp-8.5',
    'rcp26': 'https://w3id.org/hacid/data/greenhousegasconcentrationpathway/rcp-2.6',
    'rcp60': 'https://w3id.org/hacid/data/greenhousegasconcentrationpathway/rcp-6'
    }
    
def _purge_none_values(dictionary: dict) -> dict:
    return {
        k: v
        for k, v in dictionary.items()
        if v is not None
    }
    
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/dictKeys',
              arr='https://w3id.org/hacid/rml-functions/str')
def dict_keys(_str: str):
  d = str_to_dict(_str)
  return list(d.keys())
  
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/dictValues',
              arr='https://w3id.org/hacid/rml-functions/str')
def dict_values(_str: str):
  d = str_to_dict(_str)
  return list(d.values())
  
  
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/dictUUID',
              arr='https://w3id.org/hacid/rml-functions/str')
def dict_uuid(_str: str):
  d = str_to_dict(_str)
  return dict_to_uuid(d)

def str_to_dict(_str: str):
  matches = re.finditer("([a-z]+:)", _str)

  map = dict()
  prev_key = None
  prev_span = None
  for _match in matches:
    span = _match.span()
    key = _str[span[0]:span[1]-1]
    
    if prev_span and prev_key:
      value = _str[prev_span[1]:span[0]].strip()
      map[prev_key] = value

    prev_span = span
    prev_key = key

  if prev_span and prev_key:
      value = _str[prev_span[1]:].strip()
      map[prev_key] = value

  return map

def dict_to_uuid(d: dict):

  alphabet = string.ascii_lowercase + string.digits
  shortuuid.set_alphabet(alphabet)
  _str = ''
  for k,v in d.items():
    if _str:
      _str += ' '

    _str += f'{k}:{v}'

  _str = shortuuid.uuid(_str)[:8]
  
  return _str

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
    _ensemble = _id_parts[-2]
    return '.'.join(['cmip5', _model, _experiment, _ensemble])
    
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/cmip5SimulationIri',
              _id='https://w3id.org/hacid/rml-functions/id',
              _ns='https://w3id.org/hacid/rml-functions/ns')
def cmip5_simulation_iri(_id: str, _ns: str) -> str:
    return _ns + cmip5_simulation_id(_id)
    
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/cmip5OutputId',
              _id='https://w3id.org/hacid/rml-functions/id')
def cmip5_output_id(_id: str) -> str:
    #template "cmip5.%(product)s.%(institute)s.%(model)s.%(experiment)s.%(time_frequency)s.%(realm)s.%(cmor_table)s.%(ensemble)s"
    _id_parts = _id.split('|')[0].split('.')
    _model = _id_parts[3]
    _experiment = _id_parts[4]
    _ensemble = _id_parts[-2]
    _product = _id_parts[1]
    return '.'.join(['cmip5', _model, _experiment, _ensemble, _product])
    
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/cmip5OutputIri',
              _id='https://w3id.org/hacid/rml-functions/id',
              _ns='https://w3id.org/hacid/rml-functions/ns')
def cmip5_output_iri(_id: str, _ns: str) -> str:
    return _ns + cmip5_output_id(_id)
    
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/cordexDatasetId',
              _id='https://w3id.org/hacid/rml-functions/id')
def cordex_dataset_id(_id: str) -> str:
    _id_parts = _id.split('|')[0].split('.')
    return '.'.join(_id_parts[:-1])
    
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/cordexDatasetIri',
              _id='https://w3id.org/hacid/rml-functions/id',
              _ns='https://w3id.org/hacid/rml-functions/ns')
def cordex_dataset_iri(_id: str, _ns: str) -> str:
    return _ns + cordex_dataset_id(_id)

@rml_function(fun_id='https://w3id.org/hacid/rml-functions/cordexOutputId',
              _id='https://w3id.org/hacid/rml-functions/id')
def cordex_output_id(_id: str) -> str:
    # template "cordex.%(product)s.%(domain)s.%(institute)s.%(driving_model)s.%(experiment)s.%(ensemble)s.%(rcm_name)s.%(rcm_version)s.%(time_frequency)s.%(variable)s"
    _id_parts = _id.split('|')[0].split('.')
    _product = _id_parts[1]
    _domain= _id_parts[2]
    _driving_model= _id_parts[4]
    _experiment= _id_parts[5]
    _ensemble = _id_parts[6]
    _model = _id_parts[7]
    _model_version = _id_parts[8]
    return '.'.join([
        'cordex', _product,
        _domain, _driving_model, _experiment,
        _model, _model_version, _ensemble
    ])
    
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/cordexOutputIri',
              _id='https://w3id.org/hacid/rml-functions/id',
              _ns='https://w3id.org/hacid/rml-functions/ns')
def cordex_output_iri(_id: str, _ns: str) -> str:
    return _ns + cordex_output_id(_id)
    
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/cordexSimulationId',
              _id='https://w3id.org/hacid/rml-functions/id')
def cordex_simulation_id(_id: str) -> str:
    # template "cordex.%(product)s.%(domain)s.%(institute)s.%(driving_model)s.%(experiment)s.%(ensemble)s.%(rcm_name)s.%(rcm_version)s.%(time_frequency)s.%(variable)s"
    _id_parts = _id.split('|')[0].split('.')
    _domain= _id_parts[2]
    _driving_model= _id_parts[4]
    _experiment= _id_parts[5]
    _ensemble = _id_parts[6]
    _model = _id_parts[7]
    _model_version = _id_parts[8]
    return '.'.join([
        'cordex',
        _domain, _driving_model, _experiment,
        _model, _model_version, _ensemble
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
    
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/formatCordexDomain',
              _domains='https://w3id.org/hacid/rml-functions/domain',
              _template='https://w3id.org/hacid/rml-functions/template')
def format_cordex_domain(_domains: str, _template: str) -> str:
    _domain = eval(_domains)[0] if _domains[0] == "[" else _domains
    _domain_parts = _domain.split('-')
    _area_id = _domain_parts[0]
    _resolution_id = _domain_parts[1]
    _is_rotated = not (_resolution_id[-1] == 'i')
    # _rotated_area_id = _area_id if _is_rotated else None
    # _regular_area_id = None if _is_rotated else _area_id
    return _template.format_map(_purge_none_values({
        'domain': _domain,
        'area_id': _area_id,
        'resolution_id': _resolution_id,
        'rotated_domain': _domain if _is_rotated else None,
        'regular_domain': None if _is_rotated else _domain,
        'rotated_area_id': _area_id if _is_rotated else None,
        'regular_area_id': None if _is_rotated else _area_id
    }))
    
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/formatCordexRegionDescr',
              _domain_descr='https://w3id.org/hacid/rml-functions/domain-descr',
              _template='https://w3id.org/hacid/rml-functions/template')
def format_cordex_region_descr(_domain_descr: str, _template: str) -> str:
    return _template.format(region_desr = (
        _domain_descr[:-9].rstrip()
        if _domain_descr.endswith(' high res.')
        else _domain_descr
    ))
    
def round_datetime(
    _datetime: datetime, _granularity: str, _up: bool
) -> datetime:
    if _granularity is None:
        return _datetime
    _date_granularity_map = {
        '1hr': 'day',
        '3hr': 'day',
        '6hr': 'day',
        'monClim': 'mon'
    }
    _date_granularity = (
        _date_granularity_map[_granularity]
        if _granularity in _date_granularity_map
        else _granularity
    )
    _orig_date = _datetime.date()
    _orig_date_midnight = datetime.combine(
        date=_orig_date,
        time=datetime.min.time(),
        tzinfo=timezone.utc
    )
    _date = (
        _orig_date + timedelta(days=1)
        if _up and _orig_date_midnight < _datetime
        else _orig_date
    )
    if _date_granularity == 'day':
        return datetime.combine(
            date=_date,
            time=datetime.min.time(),
            tzinfo=timezone.utc
        )
    
    _month_first = _orig_date.replace(day=1)
    _month = (
        _month_first + relativedelta(months=1)
        if _up and _month_first < _orig_date
        else _month_first
    )
    if _date_granularity == 'mon':
        return datetime.combine(
            date=_month,
            time=datetime.min.time(),
            tzinfo=timezone.utc
        )

    _semester_first = _orig_date.replace(month=min(_orig_date.month,6), day=1)
    _semester = (
        _semester_first + relativedelta(months=6)
        if _up and _semester_first < _orig_date
        else _semester_first
    )
    if _date_granularity == 'sem':
        return datetime.combine(
            date=_semester,
            time=datetime.min.time(),
            tzinfo=timezone.utc
        )

    _year_first = _orig_date.replace(month=1, day=1)
    _year = (
        _year_first + relativedelta(years=1)
        if _up and _year_first < _orig_date
        else _year_first
    )
    if _date_granularity == 'yr':
        return datetime.combine(
            date=_year,
            time=datetime.min.time(),
            tzinfo=timezone.utc
        )

    print(f'Unknow granularity {_granularity}')
    raise Exception(f'Unknow granularity {_granularity}')
        
def round_datetime_iso(
    _iso_datetime: str,
    _granularity: str,
    _up: bool
) -> str:
    # if _iso_datetime.endswith('Z'):
    #     _iso_datetime = _iso_datetime[:-1]
    #     _datetime = datetime.fromisoformat(_iso_datetime)
    #     _datetime = _datetime.replace(tzinfo=timezone.utc)
    # else:
    #     _datetime = datetime.fromisoformat(_iso_datetime)
    return round_datetime(
        _datetime=isoparse(_iso_datetime),
        _granularity=_granularity,
        _up=_up
    ).isoformat().replace('+00:00', 'Z')
    
def get_start_time(
    _asserted_start_time: str,
    _asserted_end_time: str,
    _granularity: str
) -> str:
    return round_datetime_iso(
        _iso_datetime=min(_asserted_start_time, _asserted_end_time),
        _granularity=_granularity,
        _up=False
    )

def get_end_time(
    _asserted_start_time: str,
    _asserted_end_time: str,
    _granularity: str
) -> str:
    return round_datetime_iso(
        _iso_datetime=max(_asserted_start_time, _asserted_end_time),
        _granularity=_granularity,
        _up=True
    )
        
@rml_function(fun_id='https://w3id.org/hacid/rml-functions/roundDatetimeInterval',
              _start_datetime='https://w3id.org/hacid/rml-functions/startDatetime',
              _end_datetime='https://w3id.org/hacid/rml-functions/endDatetime',
              _granularity='https://w3id.org/hacid/rml-functions/granularity',
              _template='https://w3id.org/hacid/rml-functions/template')
def round_datetime_interval(
    _start_datetime: str,
    _end_datetime: str,
    _granularity: str,
    _template: str
) -> str:
    _granularity = eval(_granularity)[0]
    if _start_datetime is None or _end_datetime is None:
        return None
    return _template.format(
        start_datetime=get_start_time(_start_datetime,_end_datetime,_granularity),
        end_datetime=get_end_time(_start_datetime,_end_datetime,_granularity)
    )

_time_frequency_descr_and_value = {
    '3hr': ['three hours', 'points', 'PT3H', None],
    '6hr': ['six hours', 'rolling', 'PT6H', None],
    'day': ['day', 'rolling', 'P1D', None],
    'mon': ['month', 'rolling', 'P1M', None],
    'monClim': ['all time aggregated month of the year', 'periodic', 'P1M', 'P1Y'],
    'yr': ['year', 'rolling', 'P1Y', None],
    'fx': ['all time', None, None, None]
}

_dimensional_space_type = {
    'points': 'IntervalSampling',
    'rolling': 'RollingRegularGrid',
    'periodic': 'PeriodicRegularGrid',
    'constant': 'SingleRegionPartitioning'
}

@rml_function(fun_id='https://w3id.org/hacid/rml-functions/formatTemporalGrid',
              _start_datetime='https://w3id.org/hacid/rml-functions/startDatetime',
              _end_datetime='https://w3id.org/hacid/rml-functions/endDatetime',
              _granularity='https://w3id.org/hacid/rml-functions/granularity',
              _template='https://w3id.org/hacid/rml-functions/template')
def format_temporal_grid(
    _start_datetime: str,
    _end_datetime: str,
    _granularity: str,
    _template: str
) -> str:
    _granularity = eval(_granularity)[0]
    if _start_datetime is None or _end_datetime is None:
        return None
    
    [
        _grid_type_description,
        _dimensional_space_id,
        _grid_step,
        _grid_period
    ] = _time_frequency_descr_and_value[_granularity]
    
    def _path(_strs: list[str]) -> str:
        return "/".join([_str for _str in _strs if _str is not None])
        
    _grid_type_id = _dimensional_space_id and _path([_dimensional_space_id, _grid_step, _grid_period])
    
    _temporal_info_dict = {
        'start_datetime': get_start_time(_start_datetime,_end_datetime,_granularity),
        'end_datetime': get_end_time(_start_datetime,_end_datetime,_granularity),
        'grid_type_id': _grid_type_id,
        'grid_type_description': _grid_type_description,
        'dimensional_space_type': _dimensional_space_id and _dimensional_space_type[_dimensional_space_id],
        'grid_step': _grid_step,
        'grid_period': _grid_period
    }
    try:
        return _template.format_map(_purge_none_values(_temporal_info_dict))
    except Exception:
        return None
    
_dim_var_mapping = {
    'longitude': ['dimension/geodetic'],
    'xant': ['dimension/geodetic'],
    'xgre': ['dimension/geodetic'],
    'time': ['dimension/time'],
    'time1': ['dimension/time'],
    'time2': ['dimension/time'],
    'time3': ['dimension/time'],
    'gridlatitude': ['dimension/geodetic_lat'],
    'alevel': ['dimension/elevation'],
    'alevhalf': ['dimension/elevation'],
    'olevel': ['dimension/elevation']
}

@rml_function(fun_id='https://w3id.org/hacid/rml-functions/MIPVariableDependsFrom',
              _dimensions_str='https://w3id.org/hacid/rml-functions/dimensions',
              _ns='https://w3id.org/hacid/rml-functions/ns')
def MIP_variable_depends_from(
    _dimensions_str: str,
    _ns: str
) -> list[str]:
    _dimensions = _dimensions_str.split()
    return [
        _ns + _var
        for _dimension in _dimensions
        for _var in (
            _dim_var_mapping[_dimension]
            if _dimension in _dim_var_mapping
            else []
        )
    ]

class CSMapper(object):

    def map_to_rdf(self,
        homepath: str,
        jsonpath: str,
        columns: List,
        file_type: Literal["json","csv"],
        transpose=True,
        tpl_vars: dict = None
    ):
        
        def map_csv_file_to_rdf(input_csv_filename: str, filename_suffix: str =''):
            
            mapper = Framework.get_mapper()
            
            vars = {'CSV': input_csv_filename}
            
            if tpl_vars:
                vars.update(tpl_vars)
            
            rml_path = glob.glob(f'{homepath}/rml/*.ttl')[0]
            
            rdf_path = f'{homepath}/rdf/data{filename_suffix}.ttl'
            out = mapper.convert(rml_path, False, vars)
            out.serialize(rdf_path, format='text/turtle')
            
            mapper.reset()

        def map_json_file_to_rdf(input_json_filename: str, filename_suffix: str =''):
            
            json_data = json.load(open(input_json_filename,mode='r',encoding='utf-8'))
                                    
            jsonpath_expr = parse(jsonpath)
            matches = jsonpath_expr.find(json_data)
            
            data = [match.value for match in matches]
            
            df = pd.json_normalize(data)

            if transpose:
                df = df.transpose()
                df = df.reset_index()
                df.columns = columns #.copy()

            csv_path = f'{homepath}/data/data{filename_suffix}.csv'
            df.to_csv(csv_path)
            
            map_csv_file_to_rdf(csv_path, filename_suffix=filename_suffix)
            
        def map_file_to_rdf(input_filename: str, file_type: Literal["json","csv"], filename_suffix: str =''):
            if file_type == 'json':
                map_json_file_to_rdf(input_json_filename=input_filename, filename_suffix=filename_suffix)
            elif file_type == 'csv':
                map_csv_file_to_rdf(input_csv_filename=input_filename, filename_suffix=filename_suffix)

        extension = file_type
        filenames = glob.glob(f'{homepath}/data/*.{extension}')
        if len(filenames) > 1:
            for file_index, filename in enumerate(filenames):
                print(f'{file_index}: {filename}')
                map_file_to_rdf(input_filename=filename, file_type=file_type, filename_suffix=f'-{file_index}')
        elif len(filenames) == 1:
            map_file_to_rdf(input_filename=filenames[0], file_type=file_type)

if __name__ == '__main__':
    homepath = '.'
    subfolders = sorted([ f.path for f in os.scandir(homepath) if f.is_dir() ])
    
    cs_mapper = CSMapper()
    
    for subfolder in subfolders:
        # if subfolder.endswith('cmip5'):
        if subfolder.endswith('cordex') or subfolder.endswith('cmip5'):
        # if subfolder.endswith('cordex-domains'):
        # if subfolder.endswith('cmor-tables'):
        # if subfolder.endswith('cf-standard-names'):
            print(f'Loading data from subfolder {subfolder} ...')
            conf = f'{subfolder}/conf.json'
            try:
                json_conf = json.load(open(conf,mode='r',encoding='utf-8'))
            except:
                print(f'Configuration file not found, subfolder skipped!')
                continue
            file_type = json_conf['file-type'] if 'file-type' in json_conf else 'json'
            jsonpath = json_conf['jsonpath'] if 'jsonpath' in json_conf else None
            columns = json_conf['columns'] if 'columns' in json_conf else None
            transpose = json_conf['transpose'] if 'transpose' in json_conf else True
            
            if 'vars' in json_conf:
                _vars = json_conf['vars']
            else:
                _vars = None
                
            cs_mapper.map_to_rdf(
                homepath=subfolder,
                jsonpath=jsonpath,
                columns=columns,
                file_type=file_type,
                transpose=transpose,
                tpl_vars=_vars
            )
    