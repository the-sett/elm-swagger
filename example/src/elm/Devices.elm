module Devices exposing (devices)

import Responsive exposing (Device(..), DeviceProps, ResponsiveStyle)
import TypeScale exposing (majorThird)



-- Device Configurations


sm : DeviceProps
sm =
    { device = Sm
    , baseFontSize = 14.0
    , breakWidth = 480
    , wrapperWidth = 608
    }


md : DeviceProps
md =
    { device = Md
    , baseFontSize = 15.0
    , breakWidth = 768
    , wrapperWidth = 792
    }


lg : DeviceProps
lg =
    { device = Lg
    , baseFontSize = 16.0
    , breakWidth = 992
    , wrapperWidth = 920
    }


xl : DeviceProps
xl =
    { device = Xl
    , baseFontSize = 17.0
    , breakWidth = 1200
    , wrapperWidth = 1040
    }


{-| The responsive device configuration.
-}
devices : ResponsiveStyle
devices =
    { commonStyle =
        { lineHeightRatio = 1.4
        , typeScale = majorThird
        }
    , deviceStyles =
        { sm = sm
        , md = md
        , lg = lg
        , xl = xl
        }
    }
