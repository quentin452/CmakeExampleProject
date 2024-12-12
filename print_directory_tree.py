import os

def print_directory_tree(root, prefix=""):
    # Obtenir la liste de tous les fichiers et dossiers dans le répertoire
    items = os.listdir(root)
    
    # Trier les éléments pour que les dossiers apparaissent avant les fichiers
    items.sort(key=lambda x: os.path.isdir(os.path.join(root, x)), reverse=True)
    
    # Parcourir chaque élément
    for i, item in enumerate(items):
        path = os.path.join(root, item)
        
        # Déterminer si c'est le dernier élément dans le répertoire
        is_last = i == len(items) - 1
        
        # Déterminer les symboles pour afficher la structure correctement
        connector = "└── " if is_last else "├── "
        sub_prefix = "    " if is_last else "│   "
        
        # Afficher le fichier ou dossier courant
        print(prefix + connector + item)
        
        # Si c'est un dossier, appeler récursivement cette fonction
        if os.path.isdir(path):
            print_directory_tree(path, prefix + sub_prefix)

# Spécifiez le répertoire racine ici
root_directory = "src"  # Remplacer par le chemin du dossier à parcourir
root_directory_2 = "include"

# Appeler la fonction pour afficher l'arborescence
print_directory_tree(root_directory)
print_directory_tree(root_directory_2)
