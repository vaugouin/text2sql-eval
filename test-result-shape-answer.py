"""Standalone check of the `answer` clause of the result-shape grammar (FASTAPI-TEXT2SQL-368).

    uv run --no-project python test-result-shape-answer.py     # exits 1 on a failed case
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import result_shape_assertions as rsa

SPEC = "answer !~ (tt|nm)[0-9]{7}|matching identifier|identifiant"
before_en = {"answer": "Here is the movie matching identifier tt0075314.", "representation": "card-grid"}
before_fr = {"answer": "Voici l'entité (movie) correspondant à l'identifiant tt0075314.", "representation": "card-grid"}
after_en = {"answer": "Here is the movie Taxi Driver (1976), directed by Martin Scorsese.", "representation": "card-grid"}
bare_id = {"answer": "TT15654328 is the film you asked for."}

bad = 0


def case(label, spec, resp, want):
    global bad
    ok, details = rsa.check_response(spec, resp)
    good = (ok == want and rsa.not_emitted(details) == 0)
    bad += not good
    print(f"{'ok ' if good else 'BAD'} {label}: overall={ok}  {details[0]['message'] if details else ''}")


case("-368 before, EN", SPEC, before_en, False)
case("-368 before, FR", SPEC, before_fr, False)
case("-368 after, EN", SPEC, after_en, True)
case("case-insensitive id", SPEC, bare_id, False)
case("empty answer", SPEC, {"answer": ""}, True)
case("no answer key", SPEC, {}, True)
case("=~ match", "answer =~ taxi driver", after_en, True)
case("=~ miss", "answer =~ identifier", after_en, False)
case("answer with a shape clause", SPEC + "; representation == card-grid", after_en, True)
case("answer passes, shape fails", SPEC + "; representation == number-card", after_en, False)

# The French verb "identifier" is not an identifier (2457, 2512 on 1.1.20).
case("French verb identifier", SPEC, {"answer": "Leurs crédits ne permettent pas d'identifier précisément les compositeurs."}, True)
case("person id", SPEC, {"answer": "Voici la fiche de la personne nm0000122."}, False)

# Bank-wide invariant: skipped when the question types an id, judged otherwise.
def inv(label, resp, questions, want):
    global bad
    ok, msg = rsa.check_answer_invariant(resp, *questions)
    good = (ok == want)
    bad += not good
    print(f"{'ok ' if good else 'BAD'} invariant {label}: {ok}  {msg}")


chaplin_bad = {"answer": "Here is the person matching identifier nm0000122."}
chaplin_ok = {"answer": "Here is Charlie Chaplin."}
inv("Chaplin by name, id leaked", chaplin_bad, ("Who is Charlie Chaplin?", "Qui est Charlie Chaplin ?"), False)
inv("Chaplin by name, name given", chaplin_ok, ("Who is Charlie Chaplin?", ""), True)
for q in ("Who is nm0000151?", "Serie with TMDb ID 2473", "What is the TMDb movie 27205?",
          "What is Wikidata item Q47703?", "Movies tagged with Wikidata property P136",
          "Show me the person with IMDb ID nm0000233", "tt0903747"):
    inv(f"typed id {q!r}", chaplin_bad, (q, ""), None)
for q in ("Which movies did Ridley Scott direct?", "Top 10 TMDb rated films of 1994",
          "Idris Elba films", "What did the identity thief steal in Identity Thief?"):
    inv(f"no id typed {q!r}", chaplin_ok, (q, ""), True)

for spec in ("answer == taxi", "representation =~ card", "answer(X) !~ a", "answer !~ (unclosed"):
    try:
        rsa.parse(spec)
        bad += 1
        print(f"BAD parse accepted {spec!r}")
    except ValueError as e:
        print(f"ok  parse refused {spec!r}: {e}")
sys.exit(1 if bad else 0)
