\ProvidesClass{dmins}[2022/14/02 version 0.1.1 Douwe's notulenklasse]
\NeedsTeXFormat{LaTeX2e}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}

\ProcessOptions\relax

\LoadClass{article}

\RequirePackage[modulo]{lineno}
\RequirePackage[margin=1in]{geometry}
\RequirePackage{xspace}
\RequirePackage{xparse}
\RequirePackage{fontawesome}
\RequirePackage{expl3}
% \RequirePackage{namesabbr}
\RequirePackage{tocloft}
\RequirePackage{pdfpages}
\RequirePackage{xcolor}
\RequirePackage{luacode}
\RequirePackage{xcoffins}
\RequirePackage{fancyhdr}
\RequirePackage{needspace}
\RequirePackage{graphicx}

\setlength{\parindent}{0ex}
\setlength{\parskip}{2ex}

\directlua{require "action"; require "decision"}

\ExplSyntaxOn
\tl_new:N \l_tmpc_seq
\tl_new:N \l_tmpd_seq
\tl_new:N \l_tmpe_seq

\tl_new:N \l__dmins_title_tl
\tl_new:N \l__dmins_subtitle_tl
\tl_new:N \l__dmins_organisation_tl
\tl_new:N \l__dmins_committee_tl
\tl_new:N \l__dmins_date_tl
\tl_new:N \l__dmins_time_tl
\tl_new:N \l__dmins_location_tl
\tl_new:N \l__dmins_meeting_tl
\tl_set:Nn \l__dmins_meeting_tl {vergadering}
\tl_new:N \l__dmins_chair_tl
\tl_new:N \l__dmins_minutetaker_tl
\tl_new:N \l__dmins_logo_tl
\seq_new:N \l__dmins_members_seq
\seq_new:N \l__dmins_absent_excused_seq
\seq_new:N \l__dmins_absent_not_excused_seq
\seq_new:N \l__dmins_guests_seq
\seq_new:N \l__dmins_receivers_seq
\prop_new:N \l__dmins_annotations_prop
\prop_new:N \l__dmins_functions_prop

\int_new:N \l__dmins_meetingnumber_int
\int_new:N \l__dmins_topicnumber_int
\int_new:N \l__dmins_extratopicnumber_int
\int_new:N \l__dmins_subtopicnumber_int
\int_new:N \l__dmins_extrasubtopicnumber_int
\tl_new:N \l__dmins_current_topicnumber_tl

\int_new:N \l__dmins_actionnumber_int
\int_new:N \l__dmins_decisionnumber_int

\int_new:N \l__dmins_attachment_int

\bool_new:N \l__dmins_mins_disabled_bool
\bool_new:N \l__dmins_mins_confidential_bool
\seq_new:N \l__dmins_disabled_seq
\bool_new:N \l__dmins_list_of_receivers_bool

\keys_define:nn {dmins}
{
    datum .tl_set:N = \l__dmins_date_tl,
    datum .value_required:n = true,
    tijd .code:n = {\tl_set:Nn \l__dmins_time_tl {#1~uur}},
    tijd .value_required:n = true,
    locatie .tl_set:N = \l__dmins_location_tl,
    locatie .value_required:n = true,
    voorzitter .tl_set:N = \l__dmins_chair_tl,
    notulist .tl_set:N = \l__dmins_minutetaker_tl,
    leden .code:n = {\seq_set_from_clist:Nn \l__dmins_members_seq {#1}},
    afwezigzk .code:n = {\seq_set_from_clist:Nn \l__dmins_absent_not_excused_seq {#1}},
    afwezigmk .code:n = {\seq_set_from_clist:Nn \l__dmins_absent_excused_seq {#1}},
    gasten .code:n = {\seq_set_from_clist:Nn \l__dmins_guests_seq {#1}},
    ontvangers .code:n = {\seq_set_from_clist:Nn \l__dmins_receivers_seq {#1}},
    verzendlijst .bool_set:N = \l__dmins_list_of_receivers_bool,
    verzendlijst .default:n = true,
    uit .bool_set:N = \l__dmins_mins_disabled_bool,
    uit .default:n = true,
    vertrouwelijk .bool_set:N = \l__dmins_mins_confidential_bool,
    vertrouwelijk .default:n = true,
}

\ifdefined\geenvertrouwelijk \bool_set_true:N \l__dmins_mins_confidential_bool \fi

\DeclareDocumentCommand{\logo}{m}{\tl_set:Nn \l__dmins_logo_tl {#1}}
\DeclareDocumentCommand{\titel}{m}{\tl_set:Nn \l__dmins_title_tl {#1}}
\DeclareDocumentCommand{\ondertitel}{m}{\tl_set:Nn \l__dmins_subtitle_tl {#1}}
\DeclareDocumentCommand{\vergadering}{m}{\tl_set:Nn \l__dmins_meeting_tl {#1}}
\DeclareDocumentCommand{\organisatie}{m}{\tl_set:Nn \l__dmins_organisation_tl {#1}}
\DeclareDocumentCommand{\commissie}{m}{\tl_set:Nn \l__dmins_committee_tl {#1}}
\DeclareDocumentCommand{\voorzitter}{m}{\tl_set:Nn \l__dmins_chair_tl {#1}}
\DeclareDocumentCommand{\notulist}{m}{\tl_set:Nn \l__dmins_minutetaker_tl {#1}}
\DeclareDocumentCommand{\leden}{m}{\seq_set_from_clist:Nn \l__dmins_members_seq {#1}}
\DeclareDocumentCommand{\gasten}{m}{\seq_set_from_clist:Nn \l__dmins_guests_seq {#1}}
\DeclareDocumentCommand{\annotatie}{m m}{\prop_put:Nnn \l__dmins_annotations_prop {#1} {#2}}
\DeclareDocumentCommand{\geenannotatie}{m}{\prop_remove:Nn \l__dmins_annotations_prop {#1}}
\DeclareDocumentCommand{\functie}{m m}{\prop_put:Nnn \l__dmins_functions_prop {#1} {#2}}
\DeclareDocumentCommand{\hamer}{O{\faGavel} m}{\par#1~\textit{#2}\par}
\DeclareDocumentCommand{\uitgeschakeld}{m}{\seq_set_from_clist:Nn \l__dmins_disabled_seq {#1}}
\DeclareDocumentCommand{\administratie}{}{%
\seq_concat:NNN \l_tmpa_seq \l__dmins_members_seq \l__dmins_guests_seq
\seq_concat:NNN \l_tmpa_seq \l_tmpa_seq \l__dmins_receivers_seq
\seq_map_inline:Nn \l__dmins_absent_excused_seq {\seq_remove_all:Nn \l__dmins_members_seq {##1}}
\seq_map_inline:Nn \l__dmins_absent_not_excused_seq {\seq_remove_all:Nn \l__dmins_members_seq {##1}}
\Needspace{5\baselineskip}
\phantomsection\pdfbookmark[2]{Administratie}{Administratie-\int_use:N \l__dmins_meetingnumber_int}
{\Large\bfseries Administratie}\par
\seq_set_map:NNn \l_tmpb_seq \l__dmins_members_seq {\prop_get:NnNTF \l__dmins_annotations_prop {##1} \l_tmpa_tl {##1~(\tl_use:N \l_tmpa_tl)} {##1}}
\seq_set_map:NNn \l_tmpc_seq \l__dmins_absent_excused_seq {\prop_get:NnNTF \l__dmins_annotations_prop {##1} \l_tmpa_tl {##1~(\tl_use:N \l_tmpa_tl)} {##1}}
\seq_set_map:NNn \l_tmpd_seq \l__dmins_guests_seq {\prop_get:NnNTF \l__dmins_annotations_prop {##1} \l_tmpa_tl {##1~(\tl_use:N \l_tmpa_tl)} {##1}}
\seq_set_map:NNn \l_tmpe_seq \l__dmins_absent_not_excused_seq {\prop_get:NnNTF \l__dmins_annotations_prop {##1} \l_tmpa_tl {##1~(\tl_use:N \l_tmpa_tl)} {##1}}
\begin{tabular}{l p{0.7\textwidth}}
\textbf{Aanwezige~leden} & \seq_use:Nnnn \l_tmpb_seq {~en~} {,~} {,~en~}. \\
\seq_if_empty:NF \l__dmins_absent_excused_seq {\textbf{Afwezige~leden~(m.k.)} & \seq_use:Nnnn \l_tmpc_seq {~en~} {,~} {,~en~}. \\}
\seq_if_empty:NF \l__dmins_absent_not_excused_seq {\textbf{Afwezige~leden~(z.k.)} & \seq_use:Nnnn \l_tmpe_seq {~en~} {,~} {,~en~}. \\}
\seq_if_empty:NF \l__dmins_guests_seq {\textbf{Gasten} & \seq_use:Nnnn \l_tmpd_seq {~en~} {,~} {,~en~}. \\}
\bool_if:NT \l__dmins_list_of_receivers_bool {\textbf{Verzendlijst} & \seq_use:Nnnn \l_tmpa_seq {~en~} {,~} {,~en~}. \\}
\textbf{Voorzitter} & \tl_use:N \l__dmins_chair_tl. \\
\textbf{Notulist} & \tl_use:N \l__dmins_minutetaker_tl. \\
\textbf{Tijd} & \tl_use:N \l__dmins_time_tl. \\
\textbf{Locatie} & \tl_use:N \l__dmins_location_tl.
\end{tabular}
\par
}

\cs_new:Npn \l__dmins_renew_command:Nn #1#2 {\renewcommand{#1}{#2}}
\cs_generate_variant:Nn \l__dmins_renew_command:Nn {cn}

\cs_new:Npn \l__dmins_new_command:Nn #1#2 {\newcommand{#1}{#2}}
\cs_generate_variant:Nn \l__dmins_new_command:Nn {cn}

\cs_new:Npn \l__dmins_setlength:Nn #1#2 {\setlength{#1}{#2}}
\cs_generate_variant:Nn \l__dmins_setlength:Nn {cn}

\cs_new:Npn \l__dmins_setcounter:nn #1#2 {\setcounter{#1}{#2}}
\cs_generate_variant:Nn \l__dmins_setcounter:nn {xn}

\cs_new:Npn \l__dmins_hamer:n #1 {\tl_show:n {#1} \hamer{#1}}
\cs_generate_variant:Nn \l__dmins_hamer:n {x}

\DeclareDocumentCommand{\onderwerp}{m}{%
\int_set:Nn \l__dmins_subtopicnumber_int {0}
\int_set:Nn \l__dmins_extrasubtopicnumber_int {0}
\int_gincr:N \l__dmins_topicnumber_int
\par
\Needspace{5\baselineskip}
\phantomsection\pdfbookmark[2]{#1}{Onderwerp-\int_use:N \l__dmins_meetingnumber_int-\int_to_arabic:n {\l__dmins_topicnumber_int}}
{\Large\bfseries \int_use:N \l__dmins_topicnumber_int\hspace{3ex}#1}\par
\tl_set:Nx \l__dmins_current_topicnumber_tl {\int_to_arabic:n {\l__dmins_topicnumber_int}}
\addcontentsline{ow\int_to_roman:n {\l__dmins_meetingnumber_int}}{onderwerp\int_to_roman:n {\l__dmins_meetingnumber_int}}{\protect\numberline{\tl_use:N \l__dmins_current_topicnumber_tl}#1}}

\DeclareDocumentCommand{\extraonderwerp}{m}{%
\int_set:Nn \l__dmins_subtopicnumber_int {0}
\int_set:Nn \l__dmins_extrasubtopicnumber_int {0}
\int_gincr:N \l__dmins_extratopicnumber_int
\par
\Needspace{5\baselineskip}
\phantomsection\pdfbookmark[2]{#1}{Onderwerp-\int_use:N \l__dmins_meetingnumber_int-\int_to_Roman:n {\l__dmins_topicnumber_int}}
{\Large\bfseries \int_to_Roman:n {\l__dmins_extratopicnumber_int}\hspace{3ex}#1}\par
\tl_set:Nx \l__dmins_current_topicnumber_tl {\int_to_Roman:n {\l__dmins_extratopicnumber_int}}
\addcontentsline{ow\int_to_roman:n {\l__dmins_meetingnumber_int}}{onderwerp\int_to_roman:n {\l__dmins_meetingnumber_int}}{\protect\numberline{\tl_use:N \l__dmins_current_topicnumber_tl}#1}}

\DeclareDocumentCommand{\subonderwerp}{m}{%
\int_gincr:N \l__dmins_subtopicnumber_int
\par
\Needspace{5\baselineskip}
\phantomsection\pdfbookmark[3]{#1}{SubOnderwerp-\int_use:N \l__dmins_meetingnumber_int-\int_to_arabic:n {\l__dmins_topicnumber_int}}
{\large\bfseries \tl_use:N \l__dmins_current_topicnumber_tl.\int_use:N \l__dmins_subtopicnumber_int\hspace{3ex}#1}\par
\addcontentsline{ow\int_to_roman:n {\l__dmins_meetingnumber_int}}{subonderwerp\int_to_roman:n {\l__dmins_meetingnumber_int}}{\protect\numberline{\tl_use:N \l__dmins_current_topicnumber_tl.\int_use:N \l__dmins_subtopicnumber_int}#1}}

\DeclareDocumentCommand{\extrasubonderwerp}{m}{%
\int_gincr:N \l__dmins_extrasubtopicnumber_int
\par
\Needspace{5\baselineskip}
\phantomsection\pdfbookmark[3]{#1}{SubOnderwerp-\int_use:N \l__dmins_meetingnumber_int-\int_to_Roman:n {\l__dmins_topicnumber_int}}
{\large\bfseries \tl_use:N \l__dmins_current_topicnumber_tl.\int_to_roman:n {\l__dmins_subtopicnumber_int}\hspace{3ex}#1}\par
\tl_set:Nx \l_tmpa_tl {\int_to_roman:n {\l__dmins_subtopicnumber_int}}
\addcontentsline{ow\int_to_roman:n {\l__dmins_meetingnumber_int}}{subonderwerp\int_to_roman:n {\l__dmins_meetingnumber_int}}{\protect\numberline{\tl_use:N \l__dmins_current_topicnumber_tl.\tl_use:N \l_tmpa_tl}#1}}

\DeclareDocumentCommand{\subsubonderwerp}{m}{%
\par
\Needspace{5\baselineskip}
\phantomsection\pdfbookmark[4]{#1}{SubSubOnderwerp-\int_use:N \l__dmins_meetingnumber_int-#1}
{\bfseries #1}\par
\addcontentsline{ow\int_to_roman:n {\l__dmins_meetingnumber_int}}{subsubonderwerp\int_to_roman:n {\l__dmins_meetingnumber_int}}{#1}}

\DeclareDocumentCommand{\agenda}{}{%
\Needspace{5\baselineskip}
\phantomsection\pdfbookmark[2]{Agenda}{Agenda-\int_use:N \l__dmins_meetingnumber_int}
\use:c {listofonderwerp\int_to_roman:n {\l__dmins_meetingnumber_int}}
\vspace{-2.3ex}\hrulefill
}

\DeclareDocumentCommand{\in}{m o}{
    \IfValueTF{#2}{
        \par\textit{#1~komt~de~vergadering~binnen~om~#2~uur.}\par
    }{
        \par\textit{#1~komt~de~vergadering~binnen.}\par
    }
}

\DeclareDocumentCommand{\uit}{m o}{
    \IfValueTF{#2}{
        \par\textit{#1~verlaat~de~vergadering~om~#2~uur.}\par
    }{
        \par\textit{#1~verlaat~de~vergadering.}\par
    }
}

\DeclareDocumentCommand{\open}{m o}{
    \IfValueTF{#2}{
        \hamer{#1~opent~de~vergadering~om~#2~uur.}
    }{
        \hamer{#1~opent~de~vergadering.}
    }
}

\DeclareDocumentCommand{\heropen}{m o}{
    \IfValueTF{#2}{
        \hamer{#1~heropent~de~vergadering~om~#2~uur.}
    }{
        \hamer{#1~heropent~de~vergadering.}
    }
}

\tl_new:N \l__dmins_schorst_om_tl
\tl_new:N \l__dmins_schorst_voor_tl

\keys_define:nn {dminsschorst} {
    om .code:n = {\tl_set:Nn \l__dmins_schorst_om_tl {~om~#1~uur}},
    voor .code:n = {\tl_set:Nn \l__dmins_schorst_om_tl {~voor~#1}},
}

\DeclareDocumentCommand{\schorst}{m o}{
    \IfValueT{#2}{
        \keys_set:nn {dminsschorst} {#2}
    }
    \hamer{#1~schorst~de~vergadering \tl_use:N \l__dmins_schorst_om_tl \tl_use:N \l__dmins_schorst_voor_tl.}
}

\DeclareDocumentCommand{\sluit}{m o}{
    \IfValueTF{#2}{
        \par\textit{#1~sluit~de~vergadering~om~#2~uur.}\par
    }{
        \par\textit{#1~sluit~de~vergadering.}\par
    }
}

\tl_new:N \l__dmins_attachment_fg_color_tl
\tl_new:N \l__dmins_attachment_bg_color_tl
\tl_new:N \l__dmins_attachment_name_tl
\tl_new:N \l__dmins_attachment_label_tl

\keys_define:nn {dminsattachment}
{
    fg .tl_set:N = \l__dmins_attachment_fg_color_tl,
    bg .tl_set:N = \l__dmins_attachment_bg_color_tl,
    naam .tl_set:N = \l__dmins_attachment_name_tl,
    label .tl_set:N = \l__dmins_attachment_label_tl,
}

\DeclareDocumentCommand{\bijlage}{o m}{
    \IfValueT{#1}{\keys_set:nn {dminsattachment} {#1}}
    \int_incr:N \l__dmins_attachment_int
    \tl_if_empty:NT \l__dmins_attachment_fg_color_tl {\tl_set:Nn \l__dmins_attachment_fg_color_tl {black}}
    \tl_if_empty:NT \l__dmins_attachment_name_tl {\tl_set:Nn \l__dmins_attachment_name_tl {#2}}
    \makeatletter
    \tl_if_empty:NF \l__dmins_attachment_label_tl {\def\@currentlabel{\int_to_Alph:n {\l__dmins_attachment_int}}\label{\tl_use:N \l__dmins_attachment_label_tl}}
    \tl_if_empty:NT \l__dmins_attachment_label_tl {\tl_set:Nn \l__dmins_attachment_label_tl {#2}}
    \tl_put_right:Nn \l__dmins_attachment_label_tl {-link}
    \makeatother
    \tl_set:Nn \l_tmpa_tl {\Large\textbf{Bijlage~\int_to_Alph:n \l__dmins_attachment_int :~\tl_use:N \l__dmins_attachment_name_tl}}
    \tl_if_empty:NTF \l__dmins_attachment_bg_color_tl {
        \includepdf[pages=-,pagecommand={\vspace*{-1.5cm}\color{\tl_use:N \l__dmins_attachment_fg_color_tl}\tl_use:N \l_tmpa_tl\thispagestyle{empty}},link,linkname=\tl_use:N \l__dmins_attachment_label_tl]{#2}
    }{
        \includepdf[pages=-,pagecommand={\vspace*{-1.5cm}\colorbox{\tl_use:N \l__dmins_attachment_bg_color_tl}{\color{\tl_use:N \l__dmins_attachment_fg_color_tl}\tl_use:N \l_tmpa_tl}\thispagestyle{empty}},link,linkname=\tl_use:N \l__dmins_attachment_label_tl]{#2}
    }
}

\DeclareDocumentCommand{\refbijlage}{m}{\hyperlink{#1-link.1}{bijlage~\ref*{#1}}}
\DeclareDocumentCommand{\Refbijlage}{m}{Bijlage~\ref*{#1}}

\DeclareDocumentCommand{\newap}{m m}{
\directlua{ap = add_new_ap(\int_use:N \l__dmins_meetingnumber_int, \int_use:N \l__dmins_topicnumber_int, \int_use:N \l__dmins_actionnumber_int, \luastringN{#1}, \luastringN{#2})}
\int_gincr:N \l__dmins_actionnumber_int}

\DeclareDocumentCommand{\printap}{m}{\directlua{print_ap(#1)}}

\DeclareDocumentCommand{\ap}{m m}{
    \directlua{
        ap = add_new_ap(\int_use:N \l__dmins_meetingnumber_int, \int_use:N \l__dmins_topicnumber_int, \int_use:N \l__dmins_actionnumber_int, \luastringN{#1}, \luastringN{#2})
        tex.print(ap:running_text())
    }
    \int_gincr:N \l__dmins_actionnumber_int
}

\DeclareDocumentCommand{\oap}{m m m m m}{
    \directlua{
        ap = add_new_ap(#2, nil, #3, \luastringN{#4}, \luastringN{#5}, nil)
        if~ap~then~ap.old = true; ap:set_state(\luastringN{#1})~end
    }
}

\DeclareDocumentCommand{\dumpactions}{m}{\directlua{dump_actions_list(\luastring{#1})}}
\DeclareDocumentCommand{\dumpmeetingactions}{}{\dumpactions{\int_use:N \l__dmins_meetingnumber_int aps.tex}}

\DeclareDocumentCommand{\apstate}{m m}{\directlua{change_ap_state(\luastringN{#1}, \luastringN{#2})}}

\newcommand{\doneicon}{\faCheckSquareO}
\newcommand{\actionicon}{\faSquareO}
\newcommand{\progressicon}{\faHourglassHalf}
\newcommand{\strickenicon}{\faRemove}

\DeclareDocumentCommand{\sactionlist}{}{\directlua{section_list(\int_use:N \l__dmins_meetingnumber_int, \int_use:N \l__dmins_topicnumber_int)}}
\DeclareDocumentCommand{\actionlist}{}{{\Large\bfseries Actielijst}\par\directlua{actions_list()}}
\DeclareDocumentCommand{\personsactionlist}{}{\Needspace{7\baselineskip}\phantomsection\pdfbookmark[2]{Persoonlijke~Actielijst}{PersActielijst-\int_use:N \l__dmins_meetingnumber_int}{\Large\bfseries Persoonlijke~actielijst}\par\directlua{tex.print(persons_list(true))}}
\DeclareDocumentCommand{\actpersonitem}{m}{\needspace{2\baselineskip+2\parskip}\item[\faUser] \textbf{#1}}
\DeclareDocumentCommand{\secactitem}{m m m m m}{\item[#1] #2.#3~\textbf{#4}:~#5}
\DeclareDocumentCommand{\meetactitem}{m m m m m}{\item[#1] #2.#3~\textbf{#4}:~#5}
\DeclareDocumentCommand{\persactitem}{m m m m m}{\item[#2] \hyperref[#1]{#3.#4~#5}~(p.~\pageref{#1})}
\DeclareDocumentCommand{\oldactitem}{m m m m}{\item[#1] #2.#3~#4}
\DeclareDocumentCommand{\coveractitem}{m m m m m}{\item[#1] #2.#3~\textit{\textbf{#4}:~#5}}
\DeclareDocumentCommand{\aprunning}{m m m m m}{\phantomsection(#1~#2.#3~#4)\label{#5}}

\DeclareDocumentCommand{\besluit}{m}{\directlua{dec = new_decision(\int_use:N \l__dmins_meetingnumber_int, \int_use:N \l__dmins_decisionnumber_int, \luastringN{#1}); tex.print(dec:running())}
\int_gincr:N \l__dmins_decisionnumber_int}
\DeclareDocumentCommand{\besluitenlijst}{}{\phantomsection\pdfbookmark[1]{Besluitenlijst}{Notulen-\int_use:N \l__dmins_meetingnumber_int}\addcontentsline{lom}{notulen}{Besluitenlijst}\Needspace{5\baselineskip}{\LARGE\bfseries Besluitenlijst}\directlua{tex.print(decisions_list())}}
\DeclareDocumentCommand{\decitem}{m m m o}{\item[\faGavel\ #1.#2] \IfValueTF{#4}{\hyperref[#4]{#3}}{#3}}
\DeclareDocumentCommand{\decrunning}{m m m}{\hamer{\phantomsection#1:~#2\label{#3}}}
\DeclareDocumentCommand{\dumpdecisions}{m}{\directlua{dump_decision_list(\luastring{#1})}}
\DeclareDocumentCommand{\dumpmeetingdecisions}{}{\dumpdecisions{\int_use:N \l__dmins_meetingnumber_int decs.tex}}

\int_new:N \l__dmins_vote_for_int
\int_new:N \l__dmins_vote_against_int
\int_new:N \l__dmins_vote_blanco_int
\int_new:N \l__dmins_vote_abstain_int

\keys_define:nn {dminsvote}
{
    voor .int_set:N = \l__dmins_vote_for_int,
    tegen .int_set:N = \l__dmins_vote_against_int,
    blanco .int_set:N = \l__dmins_vote_blanco_int,
    onthouding .int_set:N = \l__dmins_vote_abstain_int,
}

\DeclareDocumentCommand{\stemming}{m}{
\keys_set:nn {dminsvote} {#1}
\hamer[\faHandPaperO]{Met~\int_use:N \l__dmins_vote_for_int~\int_compare:nNnTF {\l__dmins_vote_for_int} = {1} {~stem} {~stemmen}~voor,~\int_use:N \l__dmins_vote_against_int~\int_compare:nNnTF {\l__dmins_vote_against_int} = {1} {~stem} {~stemmen}~tegen,~\int_use:N \l__dmins_vote_blanco_int~\int_compare:nNnTF {\l__dmins_vote_blanco_int} = {1} {~stem} {~stemmen}~blanco,~en~\int_use:N \l__dmins_vote_abstain_int~\int_compare:nNnTF {\l__dmins_vote_abstain_int} = {1} {~onthouding} {~onthoudingen}~is~het~voorstel~\int_compare:nNnTF {\l__dmins_vote_for_int} > {\l__dmins_vote_against_int} {aangenomen} {verworpen}.}
}

\newlistof{notulen}{lom}{Lijst~van~notulen}
\renewcommand{\cftlomtitlefont}{\LARGE\bfseries}
\DeclareDocumentCommand{\notulenlijst}{}{\listofnotulen\clearpage}

\DeclareDocumentEnvironment{vertrouwelijk}{+b}{
  \bool_if:NF \l__dmins_mins_confidential_bool {#1}
}{}

\DeclareDocumentEnvironment{rvaonly}{+b}{
  \bool_if:NT \l__dmins_mins_confidential_bool {#1}
}{}

\DeclareDocumentEnvironment{notulen}{o m +b}{%
\int_set:Nn \l__dmins_meetingnumber_int {#2}
\int_set:Nn \l__dmins_topicnumber_int {0}
\int_set:Nn \l__dmins_subtopicnumber_int {0}
\int_set:Nn \l__dmins_actionnumber_int {1}
\int_set:Nn \l__dmins_decisionnumber_int {1}
\seq_clear:N \l__dmins_absent_excused_seq
\seq_clear:N \l__dmins_absent_not_excused_seq
\seq_clear:N \l__dmins_agenda_seq
\newlistof{onderwerp\int_to_roman:n {\l__dmins_meetingnumber_int}}{ow\int_to_roman:n {\l__dmins_meetingnumber_int}}{Agenda}
\l__dmins_renew_command:cn {cftow\int_to_roman:n {\l__dmins_meetingnumber_int}titlefont} {\Large\bfseries}
\l__dmins_renew_command:cn {cftafterow\int_to_roman:n {\l__dmins_meetingnumber_int}title} {\par\noindent\hrulefill\par\vspace{-2ex}}
\l__dmins_renew_command:cn {cftonderwerp\int_to_roman:n {\l__dmins_meetingnumber_int}font} {\bfseries}
\newlistentry[onderwerp\int_to_roman:n {\l__dmins_meetingnumber_int}]{subonderwerp\int_to_roman:n {\l__dmins_meetingnumber_int}}{ow\int_to_roman:n {\l__dmins_meetingnumber_int}}{1}
\newlistentry[onderwerp\int_to_roman:n {\l__dmins_meetingnumber_int}]{subsubonderwerp\int_to_roman:n {\l__dmins_meetingnumber_int}}{ow\int_to_roman:n {\l__dmins_meetingnumber_int}}{2}
\l__dmins_setcounter:xn {ow\int_to_roman:n {\l__dmins_meetingnumber_int}depth} {3}

\keys_set:nn {dmins} {#1}
\seq_if_in:NnT \l__dmins_disabled_seq {#2} {\bool_set_true:N \l__dmins_mins_disabled_bool}

\pagestyle{fancy}
\fancyhead{}
\fancyhead[L]{\tl_use:N \l__dmins_organisation_tl}
\fancyhead[R]{Notulen~\tl_use:N \l__dmins_meeting_tl\ \int_use:N \l__dmins_meetingnumber_int}

\everypar={}

\bool_if:NTF \l__dmins_mins_disabled_bool {}{
\resetlinenumber
\phantomsection
\addcontentsline{lom}{notulen}{Notulen~\tl_use:N \l__dmins_meeting_tl{}~\int_use:N \l__dmins_meetingnumber_int}
% \medskip
\thispagestyle{plain}
\phantomsection\pdfbookmark[1]{Notulen~\tl_use:N \l__dmins_meeting_tl{}~\int_use:N \l__dmins_meetingnumber_int}{Notulen-\int_use:N \l__dmins_meetingnumber_int}
\begin{center}
    {\large \tl_use:N \l__dmins_organisation_tl \tl_if_empty:NF \l__dmins_committee_tl {:~\tl_use:N \l__dmins_committee_tl}}\\[1ex]
    {\LARGE \textbf{Notulen~\tl_use:N \l__dmins_meeting_tl{}~\int_use:N \l__dmins_meetingnumber_int}}\\[0.75ex]
    {\tl_use:N \l__dmins_date_tl}
\end{center}
#3}
}{%
\resetlinenumber
\clearpage}
\RenewDocumentCommand{\maketitle}{}{
    \seq_set_map:NNn \l_tmpa_seq \l__dmins_members_seq {\prop_get:NnNTF \l__dmins_functions_prop {##1} \l_tmpa_tl {##1~---~\tl_use:N \l_tmpa_tl} {##1}}
    \NewCoffin \result
    \NewCoffin \organisationbox
    \NewCoffin \titlebox
    \NewCoffin \subtitlebox
    \NewCoffin \datebox
    \NewCoffin \memberbox
    \NewCoffin \logobox

    \SetHorizontalCoffin \result {}
    \SetHorizontalCoffin \organisationbox {\large \tl_use:N \l__dmins_organisation_tl \tl_if_empty:NF \l__dmins_committee_tl {:~\tl_use:N \l__dmins_committee_tl}}
    \SetHorizontalCoffin \titlebox {\LARGE\textbf{\tl_use:N \l__dmins_title_tl}}
    \SetHorizontalCoffin \subtitlebox {\Large \tl_use:N \l__dmins_subtitle_tl}
    \SetHorizontalCoffin \datebox {Laatste~bewerking:~\today}
    \SetVerticalCoffin \memberbox {\CoffinWidth\titlebox} {{\large \textit{Vaste~leden:}}\\
    \seq_use:Nnnn \l_tmpa_seq {; \\} {; \\} {; \\}.}
    \tl_if_empty:NF \l__dmins_logo_tl {
    \SetHorizontalCoffin \logobox {\includegraphics[width=3cm,height=3cm,keepaspectratio]{\tl_use:N \l__dmins_logo_tl}}}

    \JoinCoffins \result \organisationbox
    \JoinCoffins \result[\organisationbox-hc,\organisationbox-b] \titlebox[hc, t](0ex, -0.75ex)
    \JoinCoffins \result[\titlebox-hc,\titlebox-b] \subtitlebox[hc, t](0ex, -0.75ex)
    \JoinCoffins \result[\subtitlebox-hc,\subtitlebox-b] \datebox[hc,t](0ex, -0.5ex)
    \JoinCoffins \result[l,b] \memberbox[l,t](0ex, -\CoffinHeight\subtitlebox-\CoffinHeight\datebox)
    \tl_if_empty:NF \l__dmins_logo_tl {
    \JoinCoffins \result[\titlebox-hc,b] \logobox[hc,t](0ex,-\CoffinHeight\subtitlebox-\CoffinHeight\datebox-4ex)}

    \thispagestyle{empty} % Don't know what this does tbh
    \newgeometry{left=0mm,bottom=0mm, top=0mm, right=0mm}
    \hspace{0pt}\vfill
    \noindent\TypesetCoffin \result(-.5\dimexpr\CoffinWidth\result\relax+.5\textwidth,0pt) % More magical incantations
    \hspace{0pt}\vfill
    \restoregeometry % Limit shitty margins to only this page
}
\ExplSyntaxOff

\DeclareDocumentCommand{\opening}{m o}{
\onderwerp{Opening}
\IfValueTF{#2}{\open{#1}[#2]}{\open{#1}}
}
\DeclareDocumentCommand{\sluiting}{m o}{
\onderwerp{Sluiting}
\IfValueTF{#2}{\sluit{#1}[#2]}{\sluit{#1}}
}
\DeclareDocumentCommand{\mededelingen}{}{\onderwerp{Mededelingen}}
\DeclareDocumentCommand{\vastagenda}{}{\onderwerp{Vaststellen agenda}}
\DeclareDocumentCommand{\vastnotulen}{}{\onderwerp{Vaststellen notulen}}
\DeclareDocumentCommand{\actiepunten}{}{\onderwerp{Actiepunten}}
\DeclareDocumentCommand{\wvttk}{}{\onderwerp{W.v.t.t.k.}}
\DeclareDocumentCommand{\rondvraag}{}{\onderwerp{Rondvraag}}
\DeclareDocumentEnvironment{ingekomenstukken}{+b}{\onderwerp{Ingekomen stukken}
\vspace{-2ex}\begin{itemize}#1\end{itemize}}{}
\DeclareDocumentCommand{\stuk}{}{\item[\faEnvelopeO]}
\DeclareDocumentCommand{\handtekening}{m m m m}{
~
\vfill
\begin{tabular}{p{5.5cm} p{3cm} p{5.5cm}}
\cline{1-1} \cline{3-3}
\\
#1 && #3 \\
#2 && #4\\
\end{tabular}
\vfill
~
}
\pagestyle{plain}

\setlength{\topsep}{0ex}
\setlength{\partopsep}{0ex}

\AtBeginDocument{\linenumbers}
