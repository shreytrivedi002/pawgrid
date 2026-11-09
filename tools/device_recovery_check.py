#!/usr/bin/env python3
"""Check force-stop recovery of the installed NORMAL debug app through ADB.
Does not modify puzzles or directly write the game database. Run after normal
`flutter build apk --debug` and installation, never against integration entry.
"""
import json
import re
import sqlite3
import subprocess
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path
PKG='com.pawgrid.pawgrid'
ROOT=Path(__file__).resolve().parents[1]

def adb(*args):return subprocess.check_output(['adb',*args])
def tree():
    adb('shell','uiautomator','dump','/sdcard/pawgrid-check.xml')
    return ET.fromstring(adb('exec-out','cat','/sdcard/pawgrid-check.xml'))
def labels():
    return [(n.attrib.get('content-desc') or n.attrib.get('text',''),n.attrib.get('bounds','')) for n in tree().iter('node')]
def tap(prefix):
    for label,bounds in labels():
        if label.startswith(prefix):
            left,top,right,bottom=map(int,re.findall(r'\d+',bounds))
            adb('shell','input','tap',str((left+right)//2),str((top+bottom)//2))
            tree() # wait for Android's accessibility UI to become idle
            return
    raise AssertionError(f'Control not found: {prefix}')
def snapshot():
    folder=Path(tempfile.mkdtemp(prefix='pawgrid-device-'))
    for name in ['pawgrid.sqlite','pawgrid.sqlite-wal','pawgrid.sqlite-shm']:
        try:(folder/name).write_bytes(adb('exec-out','run-as',PKG,'cat','app_flutter/'+name))
        except subprocess.CalledProcessError:pass
    with sqlite3.connect(folder/'pawgrid.sqlite') as db:
        rows=db.execute('select level_id,payload from saved_sessions where slot=?',('journey:journey-001',)).fetchall()
        payload=json.loads(rows[0][1])
        balance=db.execute('select coalesce(sum(amount),0) from wallet_transactions').fetchone()[0]
    return payload,balance

adb('shell','am','force-stop',PKG)
before,balance=snapshot()
try:
    adb('shell','cmd','connectivity','airplane-mode','enable')
    adb('shell','am','start','-W','-n',PKG+'/.MainActivity')
    tree()
    adb('shell','am','force-stop',PKG)
    after,balance2=snapshot()
    for key in ['marks','history','moveCount','undoCount','puzzleHash']:
        assert before[key]==after[key],key
    assert balance==balance2
    report=dict(result='PASS',moves=after['moveCount'],undoCount=after['undoCount'],
        historyEntries=len(after['history']),balance=balance2,
        checks=['actual Android force-stop','airplane-mode cold launch',
            'exact SQLite marks/history/counters/hash and seed balance retained'])
    (ROOT/'docs/device-recovery-result.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report))
finally:
    adb('shell','cmd','connectivity','airplane-mode','disable')
    adb('shell','am','start','-n',PKG+'/.MainActivity')
