"""French questions on a 5-page French claim file, sent as the PDF itself (not as images or extracted text).

    python3 run.py
"""
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent.parent / "lib"))
from bivia import bivia, file  # noqa: E402

pdf = file(HERE / "data" / "dossier_sinistre.pdf", filename="dossier_sinistre.pdf")
state = "Pièce jointe : un dossier de sinistre automobile de 5 pages (PDF). Répondez uniquement d'après le contenu du dossier."

QUESTIONS = [
    {"q": "Le sinistre a-t-il eu lieu à Lyon ?"},
    {"q": "Le conducteur du véhicule B a-t-il franchi un feu rouge ?"},
    {"q": "L'expert a-t-il jugé le véhicule économiquement irréparable ?"},
    {"q": "Le montant TTC de la facture dépasse-t-il 1 200 € ?"},
    {"q": "D'après les conditions générales, la franchise de 300 € doit-elle être appliquée à ce sinistre ?"},
    {"q": "Le sinistre a-t-il été déclaré dans le délai prévu par le contrat ?"},
    {"q": "L'assurée a-t-elle demandé un véhicule de remplacement ?"},
    {"q": "Quel est l'assureur du véhicule B ?",
     "choices": ["Assurances Rhône-Alpes Mutuelle", "Assurances Saône Avenir", "Expertises Lyonnaises"]},
    {"q": "Quelle part de responsabilité a été retenue pour l'assurée ?", "choices": ["0 %", "50 %", "100 %"]},
]

for item in QUESTIONS:
    endpoint = "/choice" if "choices" in item else "/boolean"
    body = {"state": state, "question": item["q"], "documents": [pdf], "mode": "fast", "allow_abstain": True}
    if "choices" in item:
        body["choices"] = item["choices"]
    r = bivia(endpoint, body)
    res = r["response"]
    if r["http"] != 200:
        shown = f"HTTP {r['http']} {str(res)[:160]}"
    elif res.get("status") == "abstained":
        shown = f"abstained: {res.get('abstain_reason')}"
    else:
        shown = f"{res['value']} {res['probability'] * 100:.1f}%"
    print(f"{item['q']}\n    → {shown}")
