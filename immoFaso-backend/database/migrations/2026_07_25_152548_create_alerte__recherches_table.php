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
        Schema::create('alertes_recherche', function(Blueprint $table){

    $table->uuid('id')->primary();

    $table->foreignUuid('id_user')
        ->constrained('utilisateurs')
        ->cascadeOnDelete();

    $table->json('criteres');

    $table->boolean('active')->default(true);

    $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('alerte__recherches');
    }
};
