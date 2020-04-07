# Copyright 2019 The Nomulus Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Google-style presubmits for the Nomulus project.

These aren't built in to the static code analysis tools we use (e.g. Checkstyle,
Error Prone) so we must write them manually.
"""

import os
import sys
import re

# We should never analyze any generated files
UNIVERSALLY_SKIPPED_PATTERNS = {"/build/", "cloudbuild-caches", "/out/"}
# We can't rely on CI to have the Enum package installed so we do this instead.
FORBIDDEN = 1
REQUIRED = 2


class PresubmitCheck:

  def __init__(self,
               regex,
               included_extensions,
               skipped_patterns,
               regex_type=FORBIDDEN):
    """Define a presubmit check for a particular set of files,

        The provided prefix should always or never be included in the files.

        Args:
            regex: the regular expression to forbid or require
            included_extensions: a tuple of extensions that define which files
              we run over
            skipped_patterns: a set of patterns that will cause any files that
              include them to be skipped
            regex_type: either FORBIDDEN or REQUIRED--whether or not the regex
              must be present or cannot be present.
    """
    self.regex = regex
    self.included_extensions = included_extensions
    self.skipped_patterns = UNIVERSALLY_SKIPPED_PATTERNS.union(skipped_patterns)
    self.regex_type = regex_type

  def fails(self, file):
    """ Determine whether or not this file fails the regex check.

    Args:
        file: the full path of the file to check
    """
    if not file.endswith(self.included_extensions):
      return False
    for pattern in self.skipped_patterns:
      if pattern in file:
        return False
    with open(file, "r") as f:
      file_content = f.read()
      matches = re.match(self.regex, file_content, re.DOTALL)
      if self.regex_type == FORBIDDEN:
        return matches
      return not matches


PRESUBMITS = {
    # License check
    PresubmitCheck(
        r".*Copyright 20\d{2} The Nomulus Authors\. All Rights Reserved\.",
        ("java", "js", "soy", "sql", "py", "sh", "gradle"), {
            ".git", "/build/", "/generated/", "node_modules/",
            "JUnitBackports.java", "registrar_bin.", "registrar_dbg.",
            "google-java-format-diff.py",
            "nomulus.golden.sql", "soyutils_usegoog.js"
        }, REQUIRED):
        "File did not include the license header.",

    # Files must end in a newline
    PresubmitCheck(r".*\n$", ("java", "js", "soy", "sql", "py", "sh", "gradle"),
                   {"node_modules/"}, REQUIRED):
        "Source files must end in a newline.",

#    # System.(out|err).println should only appear in tools/
#    PresubmitCheck(
#        r".*\bSystem\.(out|err)\.print", "java", {
#            "StackdriverDashboardBuilder.java", "/tools/", "/example/",
#            "RegistryTestServerMain.java", "TestServerRule.java",
#            "FlowDocumentationTool.java"
#        }):
#        "System.(out|err).println is only allowed in tools/ packages. Please "
#        "use a logger instead.",

    # PostgreSQLContainer instantiation must specify docker tag
    PresubmitCheck(
        r"[\s\S]*new\s+PostgreSQLContainer(<[\s\S]*>)?\(\s*\)[\s\S]*",
        "java", {}):
      "PostgreSQLContainer instantiation must specify docker tag.",

    # Various Soy linting checks
    PresubmitCheck(
        r".* (/\*)?\* {?@param ",
        "soy",
        {},
    ):
        "In SOY please use the ({@param name: string} /** User name. */) style"
        " parameter passing instead of the ( * @param name User name.) style "
        "parameter pasing.",
    PresubmitCheck(
        r'.*\{[^}]+\w+:\s+"',
        "soy",
        {},
    ):
        "Please don't use double-quoted string literals in Soy parameters",
    PresubmitCheck(
        r'.*autoescape\s*=\s*"[^s]',
        "soy",
        {},
    ):
        "All soy templates must use strict autoescaping",
    PresubmitCheck(
        r".*noAutoescape",
        "soy",
        {},
    ):
        "All soy templates must use strict autoescaping",

    # various JS linting checks
    PresubmitCheck(
        r".*goog\.base\(",
        "js",
        {"/node_modules/"},
    ):
        "Use of goog.base is not allowed.",
    PresubmitCheck(
        r".*goog\.dom\.classes",
        "js",
        {"/node_modules/"},
    ):
        "Instead of goog.dom.classes, use goog.dom.classlist which is smaller "
        "and faster.",
    PresubmitCheck(
        r".*goog\.getMsg",
        "js",
        {"/node_modules/"},
    ):
        "Put messages in Soy, instead of using goog.getMsg().",
    PresubmitCheck(
        r".*(innerHTML|outerHTML)\s*(=|[+]=)([^=]|$)",
        "js",
        {"/node_modules/", "registrar_bin."},
    ):
        "Do not assign directly to the dom. Use goog.dom.setTextContent to set"
        " to plain text, goog.dom.removeChildren to clear, or "
        "soy.renderElement to render anything else",
    PresubmitCheck(
        r".*console\.(log|info|warn|error)",
        "js",
        {"/node_modules/", "google/registry/ui/js/util.js", "registrar_bin."},
    ):
        "JavaScript files should not include console logging."
}


def get_files():
  for root, dirnames, filenames in os.walk("."):
    for filename in filenames:
      yield os.path.join(root, filename)


if __name__ == "__main__":
  failed = False
  for file in get_files():
    error_messages = []
    for presubmit, error_message in PRESUBMITS.items():
      if presubmit.fails(file):
        error_messages.append(error_message)

    if error_messages:
      failed = True
      print("%s had errors: \n  %s" % (file, "\n  ".join(error_messages)))

  if failed:
    sys.exit(1)
