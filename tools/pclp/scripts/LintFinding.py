class LintFinding:
    def __init__(self, f = None):
        self.fileOfFinding = f
        self.lineOfFinding = None
        self.columnOfFinding = None
        self.messageOfFinding= ""
        self.typeOfFinding = ""
        self.IDOfFinding = ""
        self.carrotLine = ""
        self.lineOfCode = ""