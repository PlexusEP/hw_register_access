from ParsePclpOutput import ParsePclpOutput
import sys
from FindingToJUnitXML import ParseToJUnit

if __name__ == '__main__':
    PclpOutputToLint = ParsePclpOutput(sys.argv[1], sys.argv[2])
    lintToJUnitParser = ParseToJUnit(sys.argv[3])

    finding =  PclpOutputToLint.nextLint()
    while(finding != None):
        lintToJUnitParser.exportLint(finding)
        finding = PclpOutputToLint.nextLint()    
       
    lintToJUnitParser.writeCasesToFile()
