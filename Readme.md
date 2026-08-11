# Projet immoFaso

Il manquant des champs: 
public function rules(): array
{
    return [
        'titre' => 'required|string|max:150', // Ajouter si nécessaire
        'type_logement' => 'required|in:villa,appartement,studio,chambre',
        'prix_mois' => 'required|numeric|min:0',
        'surface' => 'nullable|numeric|min:0',
        'nombre_pieces' => 'nullable|integer|min:1', // Ajouté
        'description' => 'required|string',
        'equipements' => 'nullable|array',
        'equipements.*' => 'in:eau,electricite,wifi,ventilation,climatisation',

        'ville' => 'required|string|max:100',
        'quartier' => 'required|string|max:100',
        'latitude' => 'nullable|numeric|between:-90,90',
        'longitude' => 'nullable|numeric|between:-180,180',
    ];
}