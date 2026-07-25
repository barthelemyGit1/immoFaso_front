<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('annonces', function (Blueprint $table) {

    $table->uuid('id')->primary();

    $table->foreignUuid('id_proprietaire')
        ->constrained('utilisateurs')
        ->cascadeOnDelete();

    $table->foreignUuid('id_zone')
        ->constrained('zones_geographiques');

    $table->enum('type_logement',[
        'villa',
        'appartement',
        'studio',
        'chambre'
    ]);

    $table->decimal('prix_mois',12,2);

    $table->decimal('surface',8,2)->nullable();

    $table->longText('description');

    $table->enum('equipements',[
        "eau",
        "electricite",
        "wifi",
        "ventilation",
        "climatisation",
    ])->nullable();

    $table->decimal('latitude',10,7);

    $table->decimal('longitude',10,7);

    $table->enum('statut',[
        'en_attente',
        'validee',
        'rejetee',
        'louee',
        'suspendue'
    ])->default('en_attente');

    $table->text('motif_rejet')->nullable();

    $table->timestamp('date_publication')->nullable();

    $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('annonces');
    }
};
