import soccerdata as sd #biblioteca para baixar dados do FBref
import pandas as pd #biblioteca para manipulação de dados
import time #biblioteca para pausar o código e evitar bloqueio do servidor
import os #biblioteca para manipulação de arquivos e pastas

# 1. As 5 principais ligas europeias suportadas pela biblioteca
ligas_alvo = [
    'ENG-Premier League',
    'ESP-La Liga', 
    'FRA-Ligue 1', 
    'GER-Bundesliga', 
    'ITA-Serie A'
]

# 2. As temporadas completas que formarão nosso histórico
temporadas_alvo = ['2122', '2223', '2324', '2425', '2526']

#defino as pastas onde os arquivos serão salvos, para manter a organização
pastas_ligas = {
    'ENG-Premier League': 'Premier_League',
    'ESP-La Liga': 'La_Liga',
    'ITA-Serie A': 'Serie_A_Italiana',
    'GER-Bundesliga': 'Bundesliga',
    'FRA-Ligue 1': 'Ligue_1'
}

#defino as pastas onde os arquivos serão salvos, para manter a organização
pastas_temporadas = {
    '2122': '2021-2022',
    '2223': '2022-2023',
    '2324': '2023-2024',
    '2425': '2024-2025',
    '2526': '2025-2026'
}

# 3. O Loop: Passando por cada liga e cada ano
for liga in ligas_alvo:
    for temporada in temporadas_alvo:
        print(f"-> Extraindo: {liga} (Temporada {temporada})...")
        
        try:
            # Conecta e baixa os dados do FBref
            fbref = sd.FBref(leagues=liga, seasons=temporada)
            df = fbref.read_player_season_stats(stat_type="playing_time")
            df = df.reset_index()
            
            # Formata o nome do arquivo para ficar organizado
            nome_limpo_liga = liga.replace(' ', '_').replace('-', '_')
            nome_arquivo = f"{nome_limpo_liga}_{temporada}_playing_time.csv"

            #junta as duas pastas (liga e temporada) para salvar o arquivo na pasta correta
            pasta = os.path.join(
                pastas_ligas[liga],
                pastas_temporadas[temporada]
            )

            #defino o caminho completo do arquivo, incluindo a pasta e o nome do arquivo (jogue o arquivo csv na pasta correta)
            caminho = os.path.join(
                pasta,
                nome_arquivo
            )
            
            # Salva na pasta definida anteriormente
            df.to_csv(caminho, index=False, encoding='utf-8-sig')
            print(f"   [OK] Arquivo salvo: {nome_arquivo}")
            
        except Exception as e:
            print(f"   [ERRO] Falha ao baixar {liga} - {temporada}. Detalhe: {e}")
        
        # 4.Pausa para não ser bloqueado
        print("   Aguardando 7 segundos para evitar bloqueio do servidor...\n")
        time.sleep(7)

print("--- EXTRAÇÃO CONCLUÍDA COM SUCESSO! ---")
