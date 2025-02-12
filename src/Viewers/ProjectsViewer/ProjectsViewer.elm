module Viewers.ProjectsViewer.ProjectsViewer exposing (projectViewer)

import Animator exposing (..)
import Element exposing (..)
import Element.Background as Background
import Element.Events as Events
import Element.Font as Font
import Element.Input as Events
import Funcs exposing (styleWhen, when)
import Html.Attributes
import Project exposing (Footage(..), Medium(..))
import Types exposing (..)
import Viewers.ProjectsViewer.CenterView.CenterView exposing (centerViewer)
import Viewers.ProjectsViewer.Description exposing (description)
import Viewers.ProjectsViewer.ProjectPicker exposing (projectPicker)


activeViewPartAnimation : Model -> ViewerPart -> Float -> Float -> Float
activeViewPartAnimation model viewPart from to =
    Animator.move model.activeViewerPart <|
        \state -> when (state == viewPart) (Animator.at to) (Animator.at from)


hoverAnimation : Model -> ViewerPart -> Float -> Float -> Float
hoverAnimation model viewPart from to =
    Animator.move model.hovered <|
        \state -> when (state == viewPart) (Animator.at to) (Animator.at from)


projectViewer : Model -> Element Msg
projectViewer model =
    let
        flowDirection =
            when model.onMobile column row

        partBanner partName part =
            el
                ([ Font.color <| rgb 1 1 1, centerY, centerX, alpha <| activeViewPartAnimation model part 1 0 ]
                    ++ when model.onMobile [ Font.size 60 ] [ Element.rotate <| pi * 0.5, Font.size 30 ]
                )
            <|
                text partName

        partTitle partName part =
            el
                [ padding 5
                , when (part == ProjectPicker) alignRight alignLeft
                , when model.onMobile (Font.size 60) (Font.size 30)
                , Font.color <| rgb 0.9 0.9 0.9
                , alpha <| activeViewPartAnimation model part 0 1
                ]
            <|
                text partName

        partSize part =
            if not model.onMobile then
                [ width (fill |> (maximum <| round <| activeViewPartAnimation model part 80 400)) ]

            else
                [ height (fill |> (maximum <| round <| activeViewPartAnimation model part 80 (toFloat model.screenSize.h))) ]

        partColor part =
            Background.color <| rgba 0.3 0.3 (activeViewPartAnimation model part 0.7 0.5) 1
    in
    flowDirection [ width fill, height fill ]
        [ {- DESCRIPTION column -}
          column
            -- overwriting the width or height fills based on device
            (([ width fill, height fill ] ++ partSize Description)
                ++ [ alignLeft
                   , partColor Description
                   , Element.htmlAttribute <|
                        Html.Attributes.style "overflow"
                            (if Animator.arrived model.activeViewerPart /= Types.Description then
                                "clip"

                             else
                                "scroll"
                            )
                   , Element.htmlAttribute <| Html.Attributes.style "height" "100vh"
                   , pointer
                   , inFront <| partBanner "DESCRIPTION" Description
                   , Events.onMouseEnter <| NewHover Description
                   , Events.onMouseLeave <| NewHover Background
                   , Events.onClick <| NewPagePartActive Description
                   ]
                ++ styleWhen (Animator.current model.activeViewerPart == ProjectPicker)
                    [ alpha <| hoverAnimation model Description 1 0.7
                    , moveLeft <| hoverAnimation model Description 0 3
                    ]
             -- ++ when model.onMobile [ Events.onClick <| NewPagePartHovered Description ] [ Events.onMouseEnter <| NewPagePartHovered Description ]
            )
            [ partTitle "DESCRIPTION" Description
            , description
                [ height fill
                , width fill
                , alpha <| activeViewPartAnimation model Description 0 1

                -- , alpha <| when (Animator.current model.activeViewerPart == Description) 1 0
                ]
                model.projectTransition
                model.onMobile
                model.activeViewerPart
            ]

        {- CENTER VIEWER element -}
        , flowDirection
            ([ height fill, width fill, centerX, clipX ]
                ++ styleWhen (not model.onMobile)
                    [ -- Events.onMouseEnter <| NewPagePartHovered Description
                      paddingXY (round <| activeViewPartAnimation model Background 25 200) 25
                    ]
            )
            [ centerViewer
                [ width fill, centerY, padding 50 ]
                model.projectTransition
                model.footageTransition
                model.footageAbout
                model.footageMuted
                model.onMobile
            ]

        {- PROJECT PICKER element -}
        , column
            (([ width fill, height fill, clipY ] ++ partSize ProjectPicker)
                ++ [ alignRight
                   , pointer
                   , partColor ProjectPicker
                   , Element.htmlAttribute <|
                        Html.Attributes.style "overflow"
                            (if Animator.arrived model.activeViewerPart /= Types.ProjectPicker then
                                "clip"

                             else
                                "scroll"
                            )
                   , Element.htmlAttribute <| Html.Attributes.style "height" "100vh"
                   , inFront <| partBanner "PROJECT PICKER" ProjectPicker
                   , Events.onClick <| NewPagePartActive ProjectPicker
                   , Events.onMouseEnter <| NewHover ProjectPicker
                   , Events.onMouseLeave <| NewHover Background
                   ]
                ++ styleWhen (Animator.current model.activeViewerPart == Description)
                    [ alpha <| hoverAnimation model ProjectPicker 1 0.7
                    , moveRight <| hoverAnimation model ProjectPicker 0 3
                    ]
             -- ++ when model.onMobile [ Events.onClick <| NewPagePartHovered ProjectPicker ] [ Events.onMouseEnter <| NewPagePartHovered ProjectPicker ]
            )
          <|
            [ partTitle "PROJECT PICKER" ProjectPicker
            , projectPicker
                [ width fill, height fill, alpha <| activeViewPartAnimation model ProjectPicker 0 1 ]
                model
            ]
        ]
