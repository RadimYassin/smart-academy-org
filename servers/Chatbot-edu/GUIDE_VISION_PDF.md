# 🖼️ Guide d'Utilisation - EduBot Vision & PDF

## ✅ Installation Terminée !

Dépendances installées :
- ✅ pdf2image (conversion PDF → images)
- ✅ pillow (traitement d'images)
- ✅ OpenAI GPT-4o Vision

---

## 📸 Mode 1: Analyse d'Images (`chatbot_image.py`)

### Lancer
```powershell
python chatbot_image.py
```

### Fonctionnalités

**Option 1: Vision Seule**
- Analyse pure de l'image par GPT-4o
- Parfait pour: diagrammes, screenshots, schémas

**Option 2: Hybride (Vision + RAG)**
- Combine analyse de l'image + recherche dans vos cours
- Parfait pour: exercices nécessitant théorie + pratique

### Exemples d'Utilisation

**Diagramme UML:**
```
📁 Chemin: C:\Images\diagramme_classe.png
❓ Question: "Explique ce diagramme UML"
```

**Screenshot de Code:**
```
📁 Chemin: C:\Screenshots\code_java.jpg  
❓ Question: "Qu'est-ce que ce code fait ?"
```

**Schéma Technique:**
```
📁 Chemin: ./schema_heritage.png
❓ Question: "Explique le concept illustré"
```

---

## 📄 Mode 2: Analyse de PDFs (`chatbot_pdf_image.py`)

### Lancer
```powershell
python chatbot_pdf_image.py
```

### Fonctionnalités

**Option 1: PDF Complet**
- Analyse toutes les pages du PDF
- ⚠️ Attention aux coûts si PDF volumineux

**Option 2: Page Spécifique**
- Analyse seulement une page
- Recommandé pour économiser

### Exemples d'Utilisation

**Exercice Scanné:**
```
📁 Chemin: C:\Documents\exercice_java.pdf
📑 Page: 3
❓ Question: "Aide-moi à résoudre cet exercice"
```

**Page de Cours:**
```
📁 Chemin: ./cours_poo.pdf
📑 Page: 12
❓ Question: "Explique le contenu de cette page"
```

---

## 🎯 Cas d'Usage

### 1. Diagrammes UML
```powershell
python chatbot_image.py
→ Option 1 (Vision seule)
→ Chemin: diagramme.png
→ Question: "Explique les relations entre classes"
```

### 2. Code Screenshot + Théorie
```powershell
python chatbot_image.py
→ Option 2 (Hybride)
→ Chemin: code_polymorphisme.png
→ Question: "Explique ce code et la théorie du polymorphisme"
```

### 3. Exercice PDF
```powershell
python chatbot_pdf_image.py
→ Option 2 (Page spécifique)
→ Chemin: TD_Java.pdf
→ Page: 5
→ Question: "Guide-moi pour résoudre l'exercice 3"
```

---

## 💰 Coûts

### Par Image / Page PDF
- **Analyse Vision:** ~$0.01-0.03 par image
- **Mode Hybride:** +$0.001 pour le RAG
- **Total typique:** ~$0.01-0.04 par analyse

### Pour un PDF de 10 pages
- **Vision seule:** ~$0.10-0.30
- **Avec questions:** ~$0.15-0.40

**Vos crédits gratuits ($5-18) = 150-600 analyses !**

---

## 📝 Types de Fichiers Supportés

### Images (`chatbot_image.py`)
- ✅ JPG / JPEG
- ✅ PNG
- ✅ GIF
- ✅ WebP

### PDFs (`chatbot_pdf_image.py`)
- ✅ PDF standard
- ✅ PDF scanné
- ✅ PDF avec images
- ✅ PDF d'exercices

---

## 🎓 Conseils d'Utilisation

### Pour de Meilleurs Résultats

1. **Images claires et lisibles**
   - Résolution minimum: 800x600
   - Texte bien visible

2. **Questions précises**
   - "Explique ce diagramme UML" ✅
   - "C'est quoi ça ?" ❌

3. **Mode Hybride quand approprié**
   - Utilisez Option 2 si vous voulez combiner image + théorie cours

### Économiser des Crédits

1. **Page spécifique pour PDFs**
   - Analysez seulement la page nécessaire

2. **Vision seule si suffisant**
   - Pas besoin du RAG pour des screenshots simples

---

## 🔧 Configuration Avancée

### Changer la Qualité d'Analyse

Dans `chatbot_image.py`, ligne ~95:
```python
"detail": "high"  # "high" ou "low"
```
- `high`: Meilleure qualité, plus cher
- `low`: Plus rapide, moins cher

### Augmenter les Tokens de Réponse

Ligne ~100:
```python
max_tokens=1500  # Augmentez pour réponses plus longues
```

---

## ⚠️ Limitations

**Poppler requis pour PDFs (Windows)**

Si vous obtenez une erreur avec `chatbot_pdf_image.py`:
```
poppler not found
```

Installez Poppler:
1. Téléchargez: https://github.com/oschwartz10612/poppler-windows/releases
2. Extrayez dans `C:\poppler`
3. Ajoutez `C:\poppler\Library\bin` au PATH

**OU** installez via Chocolatey:
```powershell
choco install poppler
```

---

## 🚀 Prêt à Tester !

### Test Images
```powershell
python chatbot_image.py
```

### Test PDFs
```powershell
python chatbot_pdf_image.py
```

**Amusez-vous avec votre chatbot multimodal ! 🖼️📄**
