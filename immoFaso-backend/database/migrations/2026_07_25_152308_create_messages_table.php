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
        Schema::create('messages', function(Blueprint $table){

    $table->uuid('id')->primary();

    $table->foreignUuid('id_conversation')
        ->constrained('conversations')
        ->cascadeOnDelete();

    $table->foreignUuid('id_expediteur')
        ->constrained('utilisateurs');

    $table->text('contenu');

    $table->boolean('lu')->default(false);

    $table->timestamp('date_envoi');

    $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('messages');
    }
};
