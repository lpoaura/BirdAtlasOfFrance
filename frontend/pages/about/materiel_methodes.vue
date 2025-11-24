<template>
  <v-container fluid>
    <main class="TopSection breadcrumb">
      <breadcrumb />
      <header class="header-section">
        <h2 :class="{'titrepage': true, 'hidden': isTitleHidden}" >Matériel et méthodes</h2>

        <v-menu
          v-model="menuVisible"
          class="DropdownListWrapper"
          :close-on-content-click="false"
          transition="slide-x-reverse-transition"
          offset-y
        >
          <template #activator="{ on, attrs }">
            <v-btn v-bind="attrs" class="menu-button" style="border-radius: 7px;" v-on="on">
              <h5 class="green01 fw-600 nowrap right-margin-12 " style="text-transform: none;">Table des matières</h5>
              <img src="/chevron-down-green.svg" class="DropdownListChevron">
            </v-btn>
          </template>

          <v-list class="ScrollableList">
            <v-list-item @click="onOptionClick('Option 1')">
              <a href="#section1" class="DropdownOption">1. Quelles sont les données utilisées dans ODF ?</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 2')">
              <a href="#section2" class="DropdownOption">2. Collecte des données</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 2.1')">
              <a href="#subsection2.1" class="DropdownOption">2.1. Données brutes</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 2.2')">
              <a href="#subsection2.2" class="DropdownOption">2.2. Données de synthèse</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 2.3')">
              <a href="#subsection2.3" class="DropdownOption">2.3. Une API pour un transfert automatique des données depuis les portails de collecte vers Oiseaux de France</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 3')">
              <a href="#section3" class="DropdownOption">3. Quels temporalité, rythme de mise à jour et périmètre d’intervention pour ODF ?</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 3.1')">
              <a href="#subsection3.1" class="DropdownOption">3.1. 2019-2023 : le 4ème Atlas national</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 3.2')">
              <a href="#subsection3.2" class="DropdownOption">3.2. Les territoires ultramarins dans l’aventure ODF : une première.</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 4')">
              <a href="#section4" class="DropdownOption">4. Comment sont définies les trois « saisons » dans ODF ?</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 4.1')">
              <a href="#subsection4.1" class="DropdownOption">4.1. Saison de reproduction</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 4.2')">
              <a href="#subsection4.2" class="DropdownOption">4.2. Saison d’hivernage</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 4.3')">
              <a href="#subsection4.3" class="DropdownOption">4.3. Toutes saisons</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 5')">
              <a href="#section5" class="DropdownOption">5. Le module cartographique d’ODF</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 5.1')">
              <a href="#subsection5.1" class="DropdownOption">5.1. Un module pour les observateurs</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 5.1')">
              <a href="#subsection5.2" class="DropdownOption">5.2. Entrée spatiale</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 5.2.1')">
              <a href="#subsubsection5.2.1" class="DropdownOption">5.2.1. Indice de complétude</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 5.2.2')">
              <a href="#subsubsection5.2.2" class="DropdownOption">5.2.2. Diversité spécifique</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 5.2.3')">
              <a href="#subsubsection5.2.3" class="DropdownOption">5.2.3. Tableau de bord par maille</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 5.3')">
              <a href="#subsection5.3" class="DropdownOption">5.3. Entrée espèce</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 5.4')">
              <a href="#subsection5.4" class="DropdownOption">5.4. Visualiser les EPOC</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 6')">
              <a href="#section6" class="DropdownOption">6. Les Fiches-espèces</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 6.1')">
              <a href="#subsection6.1" class="DropdownOption">6.1. Répartition</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 6.1.1')">
              <a href="#subsubsection6.1.1" class="DropdownOption">6.1.1. Maillage</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 6.1.2')">
              <a href="#subsubsection6.1.2" class="DropdownOption">6.1.2. Méthode</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 6.1.3')">
              <a href="#subsubsection6.1.3" class="DropdownOption">6.1.3. Comparaison des répartitions entre les atlas</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 6.1.4')">
              <a href="#subsubsection6.1.4" class="DropdownOption">6.1.4. Cartes supplémentaires</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 6.2')">
              <a href="#subsection6.2" class="DropdownOption">6.2. Diagrammes</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 6.2.1')">
              <a href="#subsubsection6.2.1" class="DropdownOption">6.2.1. Phénologies</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 6.2.2')">
              <a href="#subsubsection6.2.2" class="DropdownOption">6.2.2. Diagramme altitudinal</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 6.2.3')">
              <a href="#subsubsection6.2.3" class="DropdownOption">6.2.3. Taille de population</a>
            </v-list-item>
            <v-list-item @click="onOptionClick('Option 6.2.4')">
              <a href="#subsubsection6.2.4" class="DropdownOption">6.2.4. Tendance démographique</a>
            </v-list-item>
          </v-list>
        </v-menu>

      </header>
    </main>

    <section class="Section">
      <main class="content">
      <!-- Texte principal -->
        <h3 id="section1" class="h3texte">1. Quelles sont les données utilisées dans ODF ?</h3>
        <p class="black02 bottom-margin-24">
          Le projet Oiseaux de France, véritable atlas dynamique des Oiseaux de France, s’appuie sur une grande diversité 
          de jeux de données pour produire l’ensemble des informations valorisées dans les fiches-espèces, que ce soit 
          pour la mise à jour des cartes de répartition, les diagrammes de phénologie, les tendances démographiques ou 
          encore les tailles de population. 
          Basées en grande partie sur des programmes de Sciences participatives, ces données se divisent en deux 
          catégories : les données dites « brutes » et les données dites « de synthèse ».
        </p>
        <p class="black02 bottom-margin-24">
          Les données brutes, aussi appelées données primaires, sont des données non interprétées et n’ayant subi aucune 
          manipulation. 
          Dans le monde du naturalisme et de l’ornithologie, il s’agit d’observations de terrain dont les informations 
          collectées sont à minima une date, un lieu, une espèce et un auteur.
        </p>
        <p class="black02 bottom-margin-24">
          On retrouve différents types de données d’occurrences utilisées dans le cadre d’ODF :
          <ul style="list-style-type: '- '; margin-left: 20px;">
            <li>
              Les données dites opportunistes : données collectées en-dehors d’un dispositif/protocole standardisé, qui 
              est la méthode la plus couramment utilisée par les observateurs. Ces données présentent l’intérêt d’être 
              nombreuses et largement réparties sur le territoire. En revanche, elles présentent de nombreux biais : 
              <ol class="custom-ol" style="list-style-type: none; margin-top: 7px; padding-left: 20px;">
                <li>(1) Historique : les données sont bien plus nombreuses sur la période récente que passée,</li>
                <li>(2) Temporel : des périodes de l’année sont plus attractives que d’autres,</li>
                <li>(3) Spatiale : les zones les plus riches en diversité et les bassins démographiques concentrent les observateurs.</li>
              </ol> 
            </li>
          </ul>
        </p>
        <p class="black02 bottom-margin-24">
          De plus, les données opportunistes ne renseignent pas d’information sur la pression d’observation. 
          Par exemple, l’absence d’un taxon peut être aussi bien expliquée par une réelle absence (l’espèce n’a pas été 
          observée/détectée par l’observateur) qu’une fausse absence (l’observateur a détecté/observé 
          l’espèce mais n’a pas collecté la donnée).
          <ul style="list-style-type: '- '; margin-left: 20px;">
            <li>
              Les données de « listes complètes » : même si elles ne sont pas collectées au moyen d’un protocole, 
              les listes complètes apportent plusieurs informations importantes non disponibles avec les données 
              opportunistes. Tout d’abord, il s’agit de liste d’espèces notées durant une période d’observation 
              précisée par l’observateur (heure de début, et heure de fin). Enfin, durant cette séquence d’observation, 
              l’observateur précise qu’il a bien noté toutes les espèces observées. De ce fait, si une espèce n’est pas 
              présente dans une liste complète, c’est qu’elle n’a pas été détectée par l’observateur et qu’elle peut 
              donc être considérée comme une réelle absence. 
            </li>
            <li>
              Les données collectées dans le cadre de dispositifs protocolés et standardisés (EPOC-ODF, Vigie-Nature 
              par exemple) qui permettent de répondre à des questions de tendances ou d’estimations d’effectifs. Avec 
              ces données, l’effort d’échantillonnage est standardisé mais généralement leur nombre est trop faible 
              pour obtenir une couverture complète du territoire dans le cadre d’Atlas.
            </li>
          </ul>
        </p>

        <h3 id="section2" class="h3texte">2. Comment sont collectés les différents types de données ?</h3>
        <h4 id="subsection2.1" class="h4texte">2.1. Données brutes</h4>
        <p class="black02 bottom-margin-24">
          Depuis la fin des années 2000, les bases de données naturalistes ont émergé dans de nombreux territoires et ont permis 
          de fortement promouvoir la collecte de données brutes. En 2017, fruit d’un long travail de collaboration entre la LPO France 
          et l’essentiel des associations naturalistes hexagonale, est née la plateforme collaborative 
          <a class="link" href="https://www.faune-france.org" target="_blank">www.faune-france.org</a> qui permet 
          la collecte d’observations sur tout le territoire métropolitain. Des milliers d’observateurs utilisent quotidiennement cette 
          plateforme et son réseau de sites miroirs locaux (faune-nouvelle-aquitaine, faune-paca par exemple) mais aussi l’application 
          pour smartphone NaturaList qui permet de collecter les informations directement sur le terrain. Certains territoires 
          ultramarins ont également suivis cette voie en déployant des plateformes similaires à Faune-France : à La Réunion 
          (<a class="link" href="https://www.faune-reunion.fr" target="_blank">www.faune-reunion.fr</a>), à Mayotte 
          (<a class="link" href="https://www.faune-mayotte.org" target="_blank">www.faune-mayotte.org</a>), en Guyane 
          (<a class="link" href="https://www.faune-guyane.fr" target="_blank">www.faune-guyane.fr</a>) ou encore dans les Antilles 
          (<a class="link" href="https://www.faune-antilles.org" target="_blank">www.faune-antilles.org</a>). En parallèle, des 
          structures associatives partenaires du projet Oiseaux de France disposent de leurs propres bases de données souvent limitées 
          à leur territoire  d’intervention. Dans le cadre de démarches d’Atlas, il est primordial de prendre en considération 
          l’ensemble des données disponibles afin d’obtenir la meilleure couverture possible du territoire national. Sont concernées 
          entre autres les bases de données :
          <ul style="list-style-type: '- '; margin-left: 20px;">
            <li>SIRF2 pour l’ex-région Nord-Pas-de-Calais</li>
            <li>CLICNAT pour l’ex-région Picardie</li>
            <li>Nature’O’Centre pour la région Centre-val-de-Loire</li>
          </ul>
        </p>
        <p class="black02 bottom-margin-24">
          Enfin, la base de données mondiale Ebird (<a class="link" href="https://www.ebird.org" target="_blank">www.ebird.org</a>), 
          qui permet de collecter des données avifaunistiques sur l’ensemble du globe, a été mobilisée notamment pour des 
          territoires comme Saint-Pierre et Miquelon, La Guadeloupe ou encore la Nouvelle-Calédonie.
        </p>
        <p class="black02 bottom-margin-24">
          Liste de tous les jeux de données utilisés :
        </p>
        <!-- Votre tableau existant -->
        <table>
          <thead>
            <tr>
              <th>Jeux de données</th>
              <th>Territoire</th>
              <th>Année</th>
              <th>Source</th>
            </tr>
          </thead>
          <tbody v-for="(donneesbrute, index) in donneesbrutes" :key="index">
            <tr>
              <td>{{ donneesbrute.jeuxDonnees }}</td>
              <td>{{ donneesbrute.territoire }}</td>
              <td>{{ donneesbrute.annee }}</td>
              <td>
                <a :href="'https://' + donneesbrute.source" target="_blank" rel="noopener noreferrer">
                  {{ donneesbrute.source }}
                </a>
              </td>
            </tr>
          </tbody>
        </table>

        <h4 id="subsection2.2" class="h4texte">2.2. Données de synthèse</h4>
        <p>
          De nombreux jeux de données de synthèse sont valorisés dans ODF. Afin de les bancariser, la LPO 
          a développé une base de données sous la technologie GéoNature. On y retrouve des résultats de 
          dispositifs thématiques comme l’Observatoire Rapaces, l’enquête Rapaces nocturnes ou encore les 
          tendances du STOC-EPS ou des comptages Wetlands. 
        </p>
        <p>Liste des jeux de données de synthèse alimentant ODF :</p>
        <table>
          <thead>
            <tr>
              <th>Jeux de données</th>
              <th>EBV</th>
              <th>Territoire</th>
              <th>Année</th>
              <th>Source</th>
            </tr>
          </thead>
          <tbody v-for="(donneessynthese, index) in donneessyntheses" :key="index">
            <tr>
              <td>{{ donneessynthese.jeuxDonnees }}</td>
              <td>{{ donneessynthese.ebv }}</td>
              <td>{{ donneessynthese.territoire }}</td>
              <td>{{ donneessynthese.annee }}</td>
              <td>{{ donneessynthese.source }}</td>
            </tr>
          </tbody>
        </table>

        <h4 id="subsection2.3" class="h4texte">2.3. Une API pour un transfert 
          automatique des données depuis les portails de collecte vers Oiseaux de France</h4>
        <p>
          A l’exception des jeux de données issus de bases tierces qui sont importés manuellement, les données 
          brutes collectées sur des portails de type Faune-France sont automatiquement intégrées dans la base 
          de données Oiseaux de France avec le déploiement d’une API. Ainsi, toutes les heures, les nouvelles 
          données saisies ainsi que les données ayant subi une modification dans la dernière heure sont 
          transférées automatiquement et viennent alimenter les cartes de répartition. Ne sont concernées que 
          les données qui sont considérées comme valides, c’est-à-dire ne faisant pas l’objet d’une demande de 
          vérification ou de complément. 
        </p>

        <h3 id="section3" class="h3texte">3. Quels temporalité, rythme de mise à jour et 
          périmètre d’intervention pour ODF ?</h3>
        <p class="black02 bottom-margin-24">
          Oiseaux de France est un atlas dynamique et perpétuel. A la différence des atlas avifaunistiques 
          précédents, il n’a pas de période bien définie avec un début et une fin mais plutôt des « arrêts sur 
          image » réguliers qui permettront d’évaluer l’évolution des répartitions des espèces à intervalles 
          réguliers et comparables avec les atlas précédents. La périodicité de ces « arrêts sur image » est 
          également synchrone avec celle des rapportages Directive Oiseaux qui se produisent tous les 6 ans.
        </p>

        <h4 id="subsection3.1" class="h4texte">3.1. 2019-2023 : le 4ème Atlas national</h4>
        <p>
          Le premier « arrêt sur image » se concentre sur la période 2019-2023, plus précisément entre le 
          01/02/2019 et le 31/01/2024 afin de pouvoir prendre en compte les données de 4 hivers (hiver 2020/2021, 
          2021/2022, 2022/2023, 2023/2024) et 5 périodes de reproduction. A partir du 01/02/2024, un nouveau cycle 
          a débuté et s’achèvera le 31/01/2029.
        </p>

        <h4 id="subsection3.2" class="h4texte">3.2. Les territoires ultramarins dans l’aventure ODF : une première !</h4>
        <p>
          Historiquement, les atlas nationaux se sont exclusivement concentrés sur le territoire métropolitain. Avec 
          le déploiement de bases de données participatives dans plusieurs territoires ultramarins, combiné à des bases 
          de données mondiales comme Ebird, ODF ambitionne d’intégrer l’ensemble des territoires d’Outre-Mer et ainsi 
          de traiter l’ensemble de la diversité avifaunistique du pays.
        </p>

        <h3 id="section4" class="h3texte">4. Comment sont définies les trois « saisons » dans ODF ?</h3>
        <p>
          Chez les oiseaux de l’hémisphère nord, on a tendance à diviser un cycle annuel en quatre phases 
          successives : l’hivernage, la migration prénuptiale, la période de reproduction et la migration 
          postnuptiale. Bien évidemment, ce schéma peut varier suivant l’écologie des espèces, notamment 
          en fonction des stratégies de migration. Cependant, de manière globale, cette saisonnalité dans 
          le cycle annuel des oiseaux se retrouve chez la plupart des espèces : l’hivernage et la 
          reproduction comme deux phases avec une mobilité réduite ; et les deux saisons de migration 
          avec une mobilité plus importante mais qui peut varier selon les espèces (chez les sédentaires, 
          cela peut s’apparenter à de l’erratisme ou de la dispersion notamment chez les oiseaux immatures).
        </p>
        <p>
          L’aire de répartition des espèces d’oiseaux peut donc varier au cours du cycle annuel, 
          spécialement pour les espèces migratrices en fonction des déplacements saisonniers. Le premier 
          atlas national s’est concentré sur la période de reproduction (Yeatman 1976). Puis dans les 
          années 1990 ont été publiés le premier atlas des oiseaux en hiver (Yeatman-Berthelot & Jarry 
          1991) suivi du nouvel atlas des oiseaux nicheurs (Yeatman-Berthelot & Jarry 1991). Après 20 ans 
          sans mise à jour, la LPO France et la SEOF ont publié l’Atlas des oiseaux de France 
          métropolitaine (Issa & Muller 2015) qui produit des cartes de répartition à la fois pour la 
          période de reproduction et d’hivernage. ODF propose de poursuivre sur cette dynamique et de 
          produire simultanément des cartes de répartition en période de reproduction et d’hivernage pour 
          une période donnée. De plus, ODF propose également une période « Toutes saisons », c’est-à-dire 
          basée sur les données collectées tout au long de l’année. En plus de compléter les cartes de 
          reproduction et d’hivernage, cette période fournit des informations sur la répartition des 
          espèces en période de migration qui peuvent largement différer des deux autres périodes. 
        </p>

        <h4 id="subsection4.1" class="h4texte">4.1. Saison de reproduction</h4>
        <p>
          Pour définir si une espèce se reproduit dans une unité géographique, comme une maille par exemple, 
          la méthodologie Atlas s’appuie sur l’utilisation de codes-atlas ou codes de nidification. Il 
          s’agit de comportement informatif sur le statut reproducteur d’un individu. Au nombre de 16 d’après 
          la nomenclature utilisée par l’EBCC, ces codes sont classés en trois catégories : nicheur possible, 
          probable et certain. Concrètement, lors d’une sortie terrain, l’observateur va pouvoir associer un 
          code-atlas à son observation en fonction du comportement observé, de la localisation ou encore de 
          la période de l’année. 
        </p>
        <p style="text-decoration: underline">
          Cependant, il n’est pas toujours simple de statuer précisément sur le comportement reproducteur ou 
          non. C’est le cas pour des espèces qui sont à la fois nicheuse et migratrices sur notre territoire. 
          Pour beaucoup, le début de la saison de reproduction peut coïncider avec le passage migratoire des 
          populations qui se reproduisent dans le nord de l’Europe. C'est le cas du Chevalier guignette, 
          nicheur rare et localisé de certains cours d’eaux intérieurs, mais migrateur très fréquent de la 
          plupart des zones humides du territoire.
        </p>
        <p style="font-weight: 600;">
          Les données mobilisées pour produire les cartes de répartition en période de reproduction reposent 
          donc uniquement sur des observations annotées d’un code-atlas.
        </p>
        <table class="tablecodeatlas">
          <thead>
            <tr>
              <th>Numéro du code</th>
              <th>Intitulé</th>
              <th>Statut nicheur</th>
            </tr>
          </thead>
          <tbody v-for="(item, index) in filteredCodeatlas" :key="index" :class="getRowClass(index)">
            <tr>
              <td>{{ item.code }}</td>
              <td>{{ item.intitule }}</td>
              <td>{{ item.statut }}</td>
            </tr>
          </tbody>
        </table>
        <p>Consulter le <a class="link" href="https://docomm.lpo.fr/LAR/%2305%20-%202025/M%c3%a9moCodeAtlas.pdf?utm_source=Sarbacane&utm_medium=email&utm_campaign=Lettre%20au%20r%C3%A9seau%20#05-2025" target="_blank">Guide d'utilisation des codes atlas.</a></p>
        
        <h4 id="subsection4.2" class="h4texte">4.2. Saison d’hivernage</h4>
        <p>
          La saison d’hivernage a été définie selon un filtre temporel. Quelque-soit les espèces, <b style="font-weight: 600;">les données collectées entre le 1er 
          décembre de l’année N et le 31 janvier de l’année N+1 sont sélectionnées pour construire la carte de répartition en hiver.</b> 
          Suivant les espèces, la période d’hivernage peut varier fortement. Ainsi, chez le Courlis cendré, des oiseaux peuvent arriver 
          sur leur site d’hivernage courant juillet pour n’en repartir qu’en mars. Par opposition, chez la Grue cendrée, des déplacements 
          migratoires sont encore notés en décembre ce qui suggère que certains oiseaux gagnent leur zone d’hivernage très tardivement. 
          Au sein d’une même espèce, cette période d’hivernage peut donc varier fortement et il n’est pas possible la plupart du temps 
          de différencier les populations qui ont des stratégies migratoires différentes à partir des observations collectées sur le 
          terrain. Le compromis a donc été de déterminer une période d’hivernage resserrée de deux mois dans laquelle la grande majorité 
          des oiseaux sont bel et bien en phase d’hivernage.
        </p>

        <h4 id="subsection4.3" class="h4texte">4.3. Toutes saisons</h4>
        <p>
          En complément de la saison de reproduction et d’hivernage, ODF 
          propose une carte de répartition « Toutes saisons » basée sur les données collectées tout au long de l’année. Pour les espèces 
          à faible mobilité, cette carte n’apporte que peu d’informations supplémentaires. En revanche, pour des espèces migratrices, 
          particulièrement des espèces qui ne se reproduisent et/ou n’hivernent pas sur notre territoire, la carte « Toutes saisons » 
          permet de visualiser les répartitions en période de migration qui sont la plupart du temps plus étendues comme par exemple le 
          Rollier d’Europe.
        </p>

        <h3 id="section5" class="h3texte">5. Le module cartographique d’ODF</h3>

        <h4 id="subsection5.1" class="h4texte">5.1. Un module pour les observateurs</h4>
        <p>
          Accessible depuis l’onglet « Prospection » sur la page d’accueil de la plateforme Oiseaux de France, le module cartographique 
          permet de visualiser en temps réel différentes informations à destination des observateurs qui souhaite participer à ODF. 
          Imaginé pour faciliter le travail de prospection, il est possible de visualiser à la fois des informations avec une entrée 
          spatiale, comme la diversité spécifique à l’échelle d’une maille, ou avec une entrée espèce pour consulter les cartes de répartition. 
        </p>

        <h4 id="subsection5.2" class="h4texte">5.2. Entrée spatiale</h4>
        <p>
          Le module cartographique propose plusieurs informations relatives à l’avancement de l’Atlas à l’échelle des mailles de 10 x 10 km. 
          Avec la barre de recherche, il est possible de zoomer sur la carte en précisant le nom d’une commune ou bien l’identifiant de la maille 10 km.
        </p>
        
        <h5 id="subsubsection5.2.1" class="h5texte">5.2.1. Indice de complétude</h5>
        <p>
          L’indice de complétude a été construit pour mettre en évidence l’état d’avancement de l’Atlas à l’échelle d’un territoire mais aussi à l’échelle 
          d’une maille. Il s’agit de comparer la diversité spécifique d’une période dite « ancienne » par rapport à la période récente, celle de l’atlas en 
          cours. Cet indice est décliné suivant les trois périodes.
        </p>
        <P>Le calcul est relativement simple : </P>
        <p>
          <div class="formula" style="margin-bottom: 8px;">
            <span>Indice de complétude = </span>
            <div class="parentheses"><span>(</span></div>
            <div class="fraction">
                <div class="numerator">Diversité spécifique période récente</div>
                <div class="denominator">Diversité spécifique période ancienne</div>
            </div>
            <div class="parentheses"><span>)</span></div>
            <span >x 100</span>
          </div>
        </p>
        <p style="text-align: center;">
          <img src="/materiel_methodes/materiel_methodes_img1.webp" alt="Indice de complétude" class="responsive-image">
          <figcaption>Figure 1 : Extrait de l’indice de complétude à l’échelle de la France métropolitaine pour la période de reproduction.</figcaption>
        </p>
        <p>
          A l’échelle d’une maille, on peut donc évaluer facilement l’état d’avancement de la prospection dans la maille suivant la période. Si l’indice est 
          inférieur à 100, alors la diversité spécifique récente est moindre que celle connue sur la période passée. Un observateur qui souhaite effectuer 
          des prospections dans le cadre d’ODF peut donc déterminer les mailles à privilégier pour ses observations.
        </p>
        <p>
          A l’échelle d’un territoire, par exemple La Guadeloupe, l’indice de complétude proposé est la moyenne des indices à la maille. Globalement, lorsque 
          l’indice moyen approche des 100%, on peut estimer que le niveau de connaissance sur la période récente se rapproche ou atteint celui de la période passée.
        </p>

        <h5 id="subsubsection5.2.2" class="h5texte">5.2.2. Diversité spécifique</h5>
        <p>
          Il est possible de visualiser la diversité spécifique brute à l’échelle d’une maille. Cette information est complémentaire de l’indice de complétude. 
          En effet, si l’indice de complétude d’une maille a est proche de 100%, on peut considérer que le niveau de prospection de la période récente est aussi 
          important que pour la période passée, ce qui ne présage pas pour autant de la qualité de la pression de prospections dans la maille. En effet, une 
          maille faiblement prospectée sur la période passée et récente aura un indice de complétude proche de 100% au même titre qu’une maille bien prospectée 
          sur les deux périodes. Avec la diversité spécifique, il est alors possible de trancher entre ces deux possibilités. En effet, si elle est faible, 
          comparée aux mailles adjacentes, alors elle est considérée comme sous-prospectée. Si au contraire elle est élevée, le niveau de prospection de la maille 
          peut être considéré comme suffisant. 
        </p>

        <h5 id="subsubsection5.2.3" class="h5texte">5.2.3. Tableau de bord par maille</h5>
        <p>
          En cliquant sur une maille s’affiche un tableau de bord qui résume un ensemble d’informations : indice de complétude, diversité spécifique et surtout 
          la liste des espèces notée dans la maille avec comparaison entre les deux périodes. Il est alors aisé pour un observateur de trouver les espèces qui 
          ont pu être notées dans la période ancienne mais pas retrouvée dans la période récente. Il peut donc orienter ses recherches dans le cadre de 
          prospections atlas. Pour chaque espèce de la liste, le statut nicheur dans la maille est spécifié pour la période récente par l’intermédiaire d’une 
          petite pastille colorée devant le nom : jaune pour nicheur possible, orange pour nicheur probable et rouge pour nicheur certain, rien si l’espèce n’est 
          pas considérée comme nicheuse sur la base des données disponibles.
        </p>
        <p style="text-align: center;">
          <img src="/materiel_methodes/materiel_methodes_img2.webp" alt="Maille" class="responsive-image">
          <figcaption>Figure 2 : Extrait du tableau de bord pour une maille ODF.</figcaption>
        </p>

        <h4 id="subsection5.3" class="h4texte">5.3. Entrée espèce</h4>
        <p>
          L’entrée espèce permet de visualiser la répartition selon les trois périodes (reproduction, hivernage, toutes saison) sur la période récente.
        </p>
        <p style="text-align: center;">
          <img src="/materiel_methodes/materiel_methodes_img3.webp" alt="Maille_espèces" class="responsive-image">
          <figcaption>Figure 3 : Extrait du tableau de bord pour une maille ODF.</figcaption>
        </p>

        <h4 id="subsection5.4" class="h4texte">5.4. Visualiser les EPOC </h4>
        <p>
          Les EPOC (Estimation des Populations d’Oiseaux Communs)  sont un dispositif ciblant les oiseaux communs. Ceux sont des points d’écoute de 5 minutes 
          réalisés par un observateur sans contrainte de temps ou de localisation. Lancé en 2017, l’objectif de ce protocole est d’obtenir une grande quantité 
          de relevés protocolés à l’échelle du territoire afin d’estimer les effectifs nicheurs des espèces les plus communes. Afin de maximiser au mieux la 
          couverture géographique des EPOC, il est possible de visualiser les EPOC déjà réalisés sur un territoire afin de prioriser les secteurs où ils ont 
          peu nombreux. Pour afficher les EPOC, rendez-vous dans l’onglet « Couches » puis « Points EPOC ».
        </p>

        <h3 id="section6" class="h3texte">6. Les Fiches-espèces </h3>
        <p>
          A l’instar des monographies publiées dans les Atlas, les fiches-espèces vont permettre de publier et valoriser les informations et résultats 
          disponibles à l’échelle des territoires et sur une période donnée. Bien évidemment, suivant les espèces et les territoires, la quantité d’informations 
          ainsi que le rythme des actualisations varieront fortement suivant les dispositifs et les connaissances.
        </p>
        <p>
          Chaque fiche-espèce s’organise selon trois onglets. Le premier traite d’informations générales sur l’espèce avec une courte description relatant la 
          répartition ainsi que quelques éléments d’écologie et d’identification de l’espèce. On y retrouve aussi les statuts liste rouge « Monde » et 
          « Europe » mais aussi des territoires nationaux (France métropolitaine et/ou territoires ultramarins lorsque des listes rouges sont disponibles), 
          et les statuts réglementaires. Le second module, intitulé « Diagrammes », présente des informations relatives aux phénologies  ou tendances et aux 
          tailles de populations. Enfin, le troisième module, « Cartes », permettra de visualiser les répartitions en fonction des périodes (reproduction, 
          hivernage, toutes saisons) et, lorsque qu’elles sont disponibles, les répartitions des atlas passés.
        </p>

        <h4 id="subsection6.1" class="h4texte">6.1. Répartition</h4>
        <p>
          Dans l’onglet « Cartes », il est possible de visualiser la répartition de l’espèce suivant différentes modalités :
          <ul style="list-style-type: '- '; margin-left: 20px;">
            <li>la période de l’année, c’est-à-dire reproduction, hivernage ou toute saison</li>
            <li>la période historique lorsque les informations sont disponibles (principalement pour la France métropolitaine avec les Atlas historiques)</li>
            <li>le territoire (lorsque des espèces sont présentes sur plusieurs territoires)</li>
          </ul>
        </p>

        <h5 id="subsubsection6.1.1" class="h5texte">6.1.1. Maillage</h5>
        <p>
          Le maillage utilisé varie suivant les territoires, de 10 x 10 km pour les territoires les plus vastes à 1 x 1 km pour les petits archipels ou îles.
        </p>
        <table>
          <thead>
            <tr>
              <th>Territoire</th>
              <th>Maillage</th>
            </tr>
          </thead>
          <tbody v-for="(item, index) in maillages" :key="index">
            <tr>
              <td>{{ item.territoire }}</td>
              <td>{{ item.maillage }}</td>
            </tr>
          </tbody>
        </table>
        <p>
          Pour les atlas historiques, le maillage peut avoir changé au cours du temps. Outre la période 2009-2012 (AOFM) où le maillage est le même que pour ODF, 
          il a changé sur les atlas historiques 1985-1985 et 1970-1975 (maille de 20 x 27 km correspond aux cartes IGN au 1/50 000).
        </p>

        <h5 id="subsubsection6.1.2" class="h5texte">6.1.2. Méthode</h5>
        <p>
          Les cartes de répartitions correspondent à l’information de la présence/absence d’une espèce dans une maille. Il s’agit d’une information qualitative 
          et non quantitative, le nombre de données de l’espèce dans la maille n’ayant pas d’influence sur l’information donnée. Pour la période de reproduction, 
          une gradation de la nidification est proposée en fonction du code-atlas le plus élevé qui a été obtenu pour l’espèce dans la maille. Ainsi les mailles 
          peuvent être jaunes, oranges ou rouges pour respectivement un statut nicheur possible, probable ou certain. Lorsque la maille est vide, c’est que 
          l’espèce n’y pas été détectée.  Pour les périodes « toutes saisons » et « hivernage », l’information représentée est la présence (couleur)/absence 
          (vide) dans la maille. 
        </p>

        <h5 id="subsubsection6.1.3" class="h5texte">6.1.3. Comparaison des répartitions entre les atlas</h5>
        <p>
          Lorsque cela est possible, nous avons réalisé des comparaisons des cartes de répartitions entre deux périodes d’atlas. Pour le territoire métropolitain 
          il s’agit de comparer la carte de l’AOFM avec celle d’ODF. Quatre informations sont possibles pour une maille, elles sont symbolisées par une couleur 
          particulière :
          <ul style="list-style-type: '- '; margin-left: 20px;">
            <li><span style="color: #D599F1; font-weight: 600;">violet</span> pour une présence sur les deux périodes, </li>
            <li><span style="color: #5363F8; font-weight: 600;">bleu</span> pour une présence uniquement durant l’AOFM, </li>
            <li><span style="color: #E26900; font-weight: 600;">orange</span> pour une présence uniquement durant ODF (orange),</li>
            <li>vide pour une absence sur les deux périodes.</li>
          </ul>
        </p>

        <h5 id="subsubsection6.1.4" class="h5texte">6.1.4. Cartes supplémentaires</h5>
        <p>
          Pour certaines espèces, il est possible de consulter des cartes supplémentaires relatives aux résultats de suivi spécifiques comme par exemple le nombre 
          de couples nicheurs par département ou encore le nombre d’individus recensés lors de comptage au dortoir.
        </p>

        <h4 id="subsection6.2" class="h4texte">6.2. Diagrammes</h4>

        <h5 id="subsubsection6.2.1" class="h5texte">6.2.1 Phénologies</h5>
        <p>
          La phénologie annuelle de présence de l’espèce sur un territoire est calculée à partir du nombre de données collectées sur la période 2019-2023. Le 
          nombre de données est calculé par décade, c’est-à-dire par période de 10 jours (3 décades par mois, 36 décades par an) et projeté sur un histogramme. 
          L’évolution saisonnière du nombre de données collectées renseigne sur la ou les périodes où l’espèce est la plus notée sur le territoire. Cette 
          phénologie peut être représentée d’une autre manière, en utilisant les données de listes complètes (cf. partie 1). Ainsi, en calculant la fréquence 
          d’apparition de l’espèce dans les listes complètes, on obtient également une phénologie de présence de l’espèce sur le territoire qui tient compte 
          de la pression d’observation. Sur le digramme de phénologies, on retrouve ainsi deux informations : la première est la phénologie calculée avec le 
          jeu de données complet (en majorité des données opportunistes) représenté par les barres bleues ; la seconde est la phénologie à partir des listes 
          complètes représentée par la courbe verte.
        </p>
        <p>
          Dans la plupart des cas, ces pics d’observation correspondent à des pics de présence de l’espèce. Attention toutefois car dans certains cas, ces 
          pics sont en réalité des pics de détectabilité et non des pics d’abondance, notamment pour les passereaux nicheurs où l’essentiel de la détection 
          se fait par le chant nuptial.
        </p>
        <p style="text-align: center;">
          <img src="/materiel_methodes/materiel_methodes_img4.webp" alt="Phénologie" class="responsive-image">
          <figcaption>Figure 4 : Phénologie annuelle du Canard pilet d’après les données d’occurrences (opportunistes et listes complètes).</figcaption>
        </p>
        <p>
          Pour une partie des espèces, la phénologie de migration est proposée suivant la méthodologie développée dans l’Atlas des Oiseaux migrateurs de 
          France (Dupuy & Sallé 2022). Il s’agit de la somme de données qualifiées de « migration » collectées par décade au cours de l’année. La sélection 
          de ces données se fait selon différentes procédures qui varient suivant les espèces (tag « migration active » ou filtres spatiaux par exemple). 
          Pour la migration prénuptiale et postnuptiale, sont représentés sur le graphe la médiane (en pointillés) ainsi que les quantiles 5 et 95% qui 
          permettent de représenter le début et la fin de la période de migration. 
        </p>
        <p style="text-align: center;">
          <img src="/materiel_methodes/materiel_methodes_img5.webp" alt="Phénologie migration" class="responsive-image">
          <figcaption>Figure 5 : Phénologie de migration du Canard pilet d’après les données de migration.</figcaption>
        </p>
        
        <h5 id="subsubsection6.2.2" class="h5texte">6.2.2. Diagramme altitudinal</h5>
        <p>
          Le diagramme altitudinal permet de visualiser la distribution des données collectées sur le terrain suivant des tranches altitudinales qui 
          varient suivant les territoires. Sur le même graphique, l’aire en bleu représente le profil altitudinal moyen du territoire concerné. Ce graphe 
          peut s’adapter en fonction des périodes de l’année, la distribution altitudinale d’une espèce pouvant varier en fonction de la saison. 
        </p>
        <p style="text-align: center;">
          <img src="/materiel_methodes/materiel_methodes_img6.webp" alt="Répartition altitudinale des observations" class="responsive-image">
          <figcaption>Figure 6 : Diagramme altitudinal du Chocard à bec jaune en France métropolitaine, d’après les données d’occurrences. L’aire bleue représente le profil altitudinal moyen du territoire métropolitain.</figcaption>
        </p>
        
        <h5 id="subsubsection6.2.3" class="h5texte">6.2.3. Taille de population</h5>
        <p>
          Plusieurs dispositifs de suivi ont pour objectif d’obtenir des estimations d’effectifs sur un territoire et une période donnée.  Il peut 
          s’agir d’effectifs hivernaux comme le comptage national des dortoirs de cormorans ou encore le recensement des oiseaux marins nicheurs. 
          Parallèlement, des suivis spécifiques sont menés sur des espèces rares et offrent des effectifs nicheurs mis à jour tous les ans (Enquête 
          sur les nicheurs rares et menacés). Ils ont chacun un protocole spécifique associé à une méthode d’analyse des données collectées. Dans 
          cet onglet sont donc diffusés les résultats de ces dispositifs suivant différentes modalités : 
          <ul style="list-style-type: '- '; margin-left: 20px;">
            <li>histogramme avec mise à jour annuelle des effectifs,</li>
            <li>mesures à intervalles réguliers.</li>
          </ul>
        </p>
        
        <h5 id="subsubsection6.2.4" class="h5texte">6.2.4. Tendance démographique</h5>
        <p>
          A l’instar des tailles de population, il existe un certain nombre de dispositifs qui calculent des tendances démographiques pour de 
          nombreuses espèces. Le plus connu est le STOC EPS qui fournit des tendances pour plus d’une centaine d’espèces d’oiseaux communs. Le comptage 
          de la mi-janvier, décliné depuis 1967 en France métropolitaine propose également des tendances démographiques sur les populations d’oiseaux 
          d’eau en hivernage. Les résultats de ces dispositifs apparaissent sous forme de graphes dans lesquels on retrouve l’évolution annuelle de 
          l’indicateur de tendance, ainsi qu’une valeur de tendance et son intervalle de confiance pour le long-terme (généralement depuis 1980 pour 
          le Wetlands, 2001 pour le STOC) et le court-terme (12 dernières années).
        </p>
        <p style="text-align: center;">
          <img src="/materiel_methodes/materiel_methodes_img7.webp" alt="Tendance" class="responsive-image">
          <figcaption>Figure 7 : Tendance démographique de l'Alouette des champs entre 2001 et 2019, basé sur les résultats du STOC EPS.</figcaption>
        </p>

      </main>
    </section>
  </v-container>
</template>



<script>
import Breadcrumb from '~/components/layouts/Breadcrumb.vue'

export default {
  name: "SommairePage",

  components: {
    breadcrumb: Breadcrumb,
  },

  data() {
    return {
      menuVisible: false,  // Contrôle la visibilité du menu déroulant
      isTitleHidden: false,
      donneesbrutes: [
        { jeuxDonnees: "Faune-France", territoire: "France métropolitaine", annee: "Toutes périodes", source: "www.faune-france.org" },
        { jeuxDonnees: "Faune-Guyane", territoire: "Guyane", annee: "Toutes périodes", source: "www.faune-guyane.fr" },
        { jeuxDonnees: "Faune-Mayotte", territoire: "Mayotte", annee: "Toutes périodes", source: "www.faune-mayotte.org" },
        { jeuxDonnees: "Faune-Réunion", territoire: "La Réunion", annee: "Toutes périodes", source: "www.faune-reunion.fr" },
        { jeuxDonnees: "Faune-Antilles", territoire: "Antilles", annee: "Toutes périodes", source: "www.faune-antilles.org" },
        { jeuxDonnees: "Nature’O’Centre", territoire: "Centre-Val-de-Loire", annee: "Toutes périodes", source: "natureocentre.org" },
        { jeuxDonnees: "EBird", territoire: "Tous les territoires ultramarins", annee: "Toutes périodes (jusqu’à 2022)", source: "www.ebird.org" },
        { jeuxDonnees: "SIRF2", territoire: "Nord-Pas-de-Calais", annee: "2007-2023", source: "gon.fr/sirf" },
        { jeuxDonnees: "ClicNat", territoire: "Picardie", annee: "2007-2022", source: "clicnat.fr" },
        { jeuxDonnees: "LPO Normandie", territoire: "Normandie", annee: "2019-2022", source: "normandie.lpo.fr" },
        { jeuxDonnees: "Atlas des Oiseaux nicheurs de Normandie", territoire: "Normandie", annee: "2016-2019", source: "www.gonm.org/index.php?post/470" },
        { jeuxDonnees: "Parc Naturel national des Pyrénées", territoire: "Pyrénées (emprise du PNN)", annee: "1978-2023", source: "www.pyrenees-parcnational.fr/fr" },
      ],
      donneessyntheses: [
        { jeuxDonnees: "Comptage Wetlands", ebv: "Tendances", territoire: "France métropolitaine", annee: "1976 - 2023", source: "LPO France" },
        { jeuxDonnees: "STOC EPS (Vigie Nature)", ebv: "Tendances", territoire: "France métropolitaine", annee: "2001-2023", source: "MNHN/LPO" },
        { jeuxDonnees: "SHOC (Vigie Nature)", ebv: "Tendances", territoire: "France métropolitaine", annee: "2006-2023", source: "MNHN/LPO" },
        { jeuxDonnees: "LIMAT", ebv: "Effectifs nicheurs", territoire: "France métropolitaine", annee: "2021-2022", source: "OFB/LPO" },
        { jeuxDonnees: "Recensement Oiseaux marins nicheurs", ebv: "Effectifs nicheurs", territoire: "France métropolitaine", annee: "1987-2022", source: "OFB/GISOM" },
        { jeuxDonnees: "Recensement Hérons coloniaux", ebv: "Effectifs nicheurs", territoire: "France métropolitaine", annee: "", source: "Loïc Marion" },
        { jeuxDonnees: "Grands Cormorans nicheurs", ebv: "Effectifs nicheurs", territoire: "France métropolitaine", annee: "", source: "Loïc Marion" },
        { jeuxDonnees: "EPOC", ebv: "Effectifs nicheurs", territoire: "France métropolitaine", annee: "2017-2023", source: "LPO/MNHN" },
        { jeuxDonnees: "Enquête Nicheurs Rares et Menacées (ENRM) métropole", ebv: "Effectifs nicheurs", territoire: "France métropolitaine", annee: "Toutes périodes", source: "LPO" },
        { jeuxDonnees: "Observatoire rapaces", ebv: "Effectifs nicheurs", territoire: "France métropolitaine",annee: "2000-2023", source: "LPO" },
        { jeuxDonnees: "Enquête rapaces nocturnes", ebv: "Effectifs nicheurs", territoire: "France métropolitaine", annee: "2015-2019", source: "LPO/GODS/CEBC" },
        { jeuxDonnees: "Enquête Busards-Milan", ebv: "Effectifs nicheurs", territoire: "France métropolitaine", annee: "2008-2023", source: "LPO/IMBE" },
        { jeuxDonnees: "Enquête Nicheurs Rares et Menacées (ENRM) Outre-Mer", ebv: "Effectifs nicheurs", territoire: "Outre-Mer", annee: "Toutes périodes", source: "LPO" },
        { jeuxDonnees: "Atlas des Oiseaux marins Nicheurs d’Outre-mer", ebv: "Effectifs nicheurs", territoire: "Outre-Mer", annee: "Toutes périodes", source: "LPO" },
        { jeuxDonnees: "Comptage dortoir Cormorans", ebv: "Effectifs hivernants", territoire: "France métropolitaine", annee: "", source: "Loïc Marion" },
        { jeuxDonnees: "Comptage Grue cendrée", ebv: "Effectifs hivernants", territoire: "France métropolitaine", annee: "", source: "LPO Champagne-Ardenne" },
        { jeuxDonnees: "Comptage dortoir Milan royal", ebv: "Effectifs hivernants", territoire: "France métropolitaine", annee: "", source: "LPO" },
        { jeuxDonnees: "Enquête Laridés hivernants", ebv: "Effectifs hivernants", territoire: "France métropolitaine", annee: "1994-2023", source: "LPO" },
      ],
      codeatlas: [
        { code: "1", intitule: "Observation de l'espèce pendant la période de nidification dans un biotope favorable", statut: "Possible"},
        { code: "2", intitule: "Mâle chanteur (ou cris de nidification) en période de reproduction", statut: "Possible"},
        { code: "3", intitule: "Couple observé dans un habitat favorable durant la saison de reproduction", statut: "Probable"},
        { code: "4", intitule: "Comportement territorial observé sur un même territoire 2 journées différentes à 7 jours ou plus d'intervalle. Observation simultanée de deux mâles chanteurs ou plus sur un même site", statut: "Probable"},
        { code: "5", intitule: "Parades nuptiales ou accouplement ou échange de nourriture entre adultes", statut: "Probable"},
        { code: "6", intitule: "Fréquentation d’un site de nid potentiel (distinct d'un site de repos)", statut: "Probable"},
        { code: "7", intitule: "Signes ou cris d’inquiétude d’un individu adulte", statut: "Probable"},
        { code: "8", intitule: "Présence de plaques incubatrices. (Observation sur un oiseau en main)", statut: "Probable"},
        { code: "9", intitule: "Construction d’un nid, creusement d’une cavité", statut: "Probable"},
        { code: "10", intitule: "Adulte feignant une blessure ou cherchant à détourner l’attention", statut: "Certain"},
        { code: "11", intitule: "Nid utilisé récemment ou coquilles vides (oeuf pondu pendant l’enquête)", statut: "Certain"},
        { code: "12", intitule: "Jeunes fraîchement envolés (espèces nidicoles) ou poussins (espèces nidifuges)", statut: "Certain"},
        { code: "13", intitule: "Adulte entrant ou quittant un site de nid (incluant les nids situés trop haut ou les cavités et nichoirs, le contenu du nid n’ayant pu être examiné)", statut: "Certain"},
        { code: "14", intitule: "Adulte transportant des sacs fécaux ou de la nourriture pour les jeunes", statut: "Certain"},
        { code: "15", intitule: "Nid avec adulte vu couvant ou contenant des œufs", statut: "Certain"},
        { code: "16", intitule: "Nid avec jeune(s) (vu ou entendu)", statut: "Certain"},
      ],
      maillages: [
        { territoire: "France métropolitaine", maillage: "10 km" },
        { territoire: "Guadeloupe", maillage: "5 km" },
        { territoire: "Martinique", maillage: "5 km" },
        { territoire: "Saint-Martin", maillage: "1 km" },
        { territoire: "Saint-Barthélemy", maillage: "1 km" },
        { territoire: "Réunion", maillage: "5 km" },
        { territoire: "Mayotte", maillage: "5 km" },
        { territoire: "Saint-Pierre et Miquelon", maillage: "5 km" },
        { territoire: "Nouvelle-Calédonie", maillage: "10 km" },
        { territoire: "TAAFs", maillage: "10 km" },
        { territoire: "Polynésie française", maillage: "5 km" },
        { territoire: "Wallis-et-Futuna", maillage: "5 km" },
      ]
    };
  },

  
  mounted() {
    window.addEventListener('scroll', this.handleScroll);
  },

  beforeDestroy() {
    window.removeEventListener('scroll', this.handleScroll);
  },

  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    };
  },

  computed: {
  filteredCodeatlas() {
    return this.codeatlas && this.codeatlas.length > 0 ? this.codeatlas : [];
    },
  },

  methods: {
    handleScroll() {
      const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
      this.isTitleHidden = scrollTop > 50; // Ajustez la valeur 50 selon vos besoins
    },
    onOptionClick(option) {
      console.log(`Option sélectionnée: ${option}`);
      this.menuVisible = false;  // Ferme le menu après la sélection
    },
    getRowClass(index) {
    if (index < 2) {return 'row-yellow';} 
    else if (index < 9) {return 'row-orange';} 
    else {return 'row-red';}
    }
  },
};
</script>



<style scoped>
.hidden {
  display: none;
}

div.container.container--fluid {
  padding-top: 68px;
}

.TopSection {
  position: fixed;
  top: 68px; /* Ajustez pour placer la section sous la navbar */
  z-index: 100; /* Assurez-vous qu'elle est au-dessus des autres éléments */
  width: 100%; /* Pour couvrir toute la largeur de la page */
  background-color: white; /* Ajoutez une couleur de fond pour masquer le contenu en dessous */
  padding: 16px 16%;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1); /* Optionnel : une ombre pour distinguer la section */
  height: auto; /* Ajustez selon votre contenu, ou utilisez une hauteur fixe si nécessaire */
}

.Section {
  margin-top: calc(68px + 52px + 40px); /* Hauteur totale de .TopSection */
  padding: 32px 16%; /* Gardez le padding existant */
}

header {
  text-align: center;
}

.titrepage{
  color: black;
  font-weight: 600; 
  text-align: center;
  font-size: 30px;
  transition: opacity 0.3s ease; /* Ajoute une transition pour un effet plus doux */
}

.v-btn {
  margin-top: 8px;
  width: 100%; /* Fait en sorte que le bouton prenne toute la largeur */
  padding: 10px;
  background-color: white !important; /* Fond blanc */
  border: 2px solid rgba(57, 118, 90, .1) !important; /* Bordure légère */
  color: #39765a !important; /* Texte noir */
  box-shadow: none !important; /* Aucune ombre */
  transition: none !important; /* Désactive la transition par défaut */
}

/* Supprime l'effet de surbrillance au survol du bouton */
.v-btn:hover {
  background-color: white !important; /* Fond reste blanc au survol */
  box-shadow: none !important; /* Pas d'ombre */
  border: 1px solid #ccc !important; /* Bordure inchangée */
  color: #39765a !important; /* Couleur du texte reste noire */
}

.v-btn.menu-button {
  transition: none !important; /* Désactive toutes les transitions */
}

.v-btn.menu-button:hover {
  background-color: white !important; /* Garde la couleur blanche au survol */
  color: #39765a !important; /* Garde la couleur du texte inchangée */
  border: 2px solid rgba(57, 118, 90, 0.1) !important; /* Garde la bordure inchangée */
  box-shadow: none !important; /* Supprime l'effet d'ombre */
  transition: none !important; /* Désactive toute animation */
}

.v-btn.menu-button:focus, 
.v-btn.menu-button:active {
  background-color: white !important; /* Garde le fond blanc */
  color: #39765a !important; /* Garde la couleur du texte inchangée */
  border: 2px solid rgba(57, 118, 90, 0.1) !important; /* Bordure inchangée */
  box-shadow: none !important; /* Pas d'ombre */
}

.v-btn.v-btn--flat.menu-button:hover, 
.v-btn.v-btn--outlined.menu-button:hover {
  background-color: white !important;
  color: #39765a !important;
  border: none !important; /* Supprime tout changement de bordure si appliqué */
  box-shadow: none !important;
}

/* Si Vuetify applique un effet de surbrillance au focus ou clic */
.v-btn:focus, .v-btn:active {
  background-color: white !important; /* Fond blanc */
  box-shadow: none !important; /* Pas d'ombre */
  border: 1px solid #ccc !important; /* Bordure inchangée */
  color: #39765a !important; /* Texte noir */
}

/* Cible les classes spécifiques Vuetify pour s'assurer qu'aucun effet n'est appliqué */
.v-btn.v-btn--flat {
  background-color: white !important; /* Fond blanc */
  color: black !important; /* Texte noir */
  box-shadow: none !important; /* Pas d'ombre */
}

.v-btn.v-btn--outlined {
  background-color: white !important; /* Fond blanc */
  color: black !important; /* Texte noir */
  box-shadow: none !important; /* Pas d'ombre */
}

/* Supprime l'effet de focus qui donne une bordure bleue par défaut */
.v-btn:focus {
  outline: none !important; /* Supprime le contour de focus */
}

.ScrollableList {
  max-height: 300px; /* Limite la hauteur */
  overflow-y: auto; /* Active le défilement vertical */
  width: 100%; /* Ajuste la largeur si nécessaire */
  border: 1px solid #ddd; /* Optionnel : ajoute une bordure */
  padding: 8px; /* Optionnel : ajoute un peu de padding */
  background-color: white; /* Optionnel : couleur de fond */
}

/* Style de la scrollbar pour personnalisation (facultatif) */
.ScrollableList::-webkit-scrollbar {
  width: 8px;
}

.ScrollableList::-webkit-scrollbar-thumb {
  background-color: #ccc; /* Couleur de la barre de défilement */
  border-radius: 4px;
}

.ScrollableList::-webkit-scrollbar-thumb:hover {
  background-color: #aaa; /* Couleur au survol */
}

.DropdownOption{
  font-size: 13px
}

/* Contenu principal */
.content {
  font-size: 14px;
}

.h3texte {
  margin-bottom: 15px;
  color: black;
  font-weight: 600;
  font-size: 22px;
  text-align: left;

}

.h4texte {
  margin-bottom: 10px;
  color: black;
  font-weight: 600;
  font-size: 18px;
}

.h5texte {
  margin-bottom: 10px;
  color: black;
  font-weight: 600;
  font-size: 14px;
}

.row-yellow {
  background-color: #fffacd; /* Jaune pâle */
}

.row-orange {
  background-color: #ffe4b5; /* Orange pâle */
}

.row-red {
  background-color: #f8d7da; /* Rouge pâle */
}


h3, h4, h5 {
  scroll-margin-top: 195px; /* Ajustez selon la hauteur de votre header */
}

/* Table */
table {
  border-collapse: collapse;
  width: 100%;
  margin: 20px 0;
}

th, td {
  border: 1px solid #ddd;
  padding: 8px;
  text-align: center;
}

th {
  background-color: #f4f4f4;
  font-weight: bold;
}

.tablecodeatlas td:nth-child(2) {
  text-align: left;
}

html {
  scroll-behavior: smooth;
}

.link {
  color : rgb(5, 44, 9);
  text-decoration: underline;
}


/* Formule mathématique */
.fraction {
  display: inline-flex;
  flex-direction: column;
  align-items: center;
}

.fraction .numerator {
  border-bottom: 1px solid black;
  width: 100%;
  text-align: center;
}

.fraction .denominator {
  text-align: center;
}

.formula {
  display: flex;
  align-items: center;
  gap: 5px;
}

.parentheses {
  font-size: 1em;
  display: inline-flex;
  flex-direction: column;
  justify-content: center;
}

.parentheses span {
  font-size: 2.5em; /* Ajuste la taille pour qu'elle corresponde à la fraction */
  line-height: 0.8;
  font-weight: 100;
}

/* Images avec une légende */
.responsive-image {
  width: 100%; /* L'image prendra toute la largeur du conteneur */
  max-width: 1000px; /* Largeur maximale pour éviter qu'elle soit trop grande */
  height: auto; /* Maintient les proportions */
}

figcaption {
  text-align: center;
  font-size: 12px;
  font-style: italic;
  color: #253571; /* Couleur de la légende */
}

/********** RESPONSIVE **********/

@media screen and (width <= 920px) {
  .TopSection {
    padding: 16px 5% 2%;
    height: auto; /* Gardez une hauteur automatique pour les petits écrans */
  }

  .Section {
    padding: 32px 5%;
    margin-top: calc(68px + 52px + 40px); /* Hauteur totale de .TopSection */
  }

  .titrepage {
    font-size: 25px;
  }
}
</style>